import AppKit
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    private let hotkeyService = HotkeyService.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupHotkeys()
        requestAccessibilityPermissions()
    }

    private func setupHotkeys() {
        hotkeyService.setup(
            onCaptureAndReformat: { [weak self] in
                Task { @MainActor in
                    await self?.handleHotkeyTrigger()
                }
            },
            onCycleMode: {
                Task { @MainActor in
                    AppState.shared.cycleToNextMode()
                }
            },
            onRevertLastChange: {
                Task { @MainActor in
                    await AppState.shared.revertLastChange()
                }
            },
            onModeSwitch: { mode in
                Task { @MainActor in
                    AppState.shared.switchToMode(mode)
                }
            }
        )
    }

    @MainActor
    private func handleHotkeyTrigger() async {
        let appState = AppState.shared

        guard !appState.isProcessing else { return }

        do {
            appState.isProcessing = true
            appState.statusMessage = "Capturing text..."

            // Capture selected text
            let capturedText = try await TextCaptureService.shared.captureSelectedText()

            guard !capturedText.isEmpty else {
                appState.showError("No text selected")
                return
            }

            // Get current mode
            guard let currentMode = appState.currentMode else {
                appState.showError("No mode selected")
                return
            }

            // Check if multi-version is enabled
            if appState.enableMultipleVersions {
                await handleMultiVersionReformat(
                    capturedText: capturedText,
                    mode: currentMode,
                    appState: appState
                )
            } else {
                await handleSingleVersionReformat(
                    capturedText: capturedText,
                    mode: currentMode,
                    appState: appState
                )
            }

        } catch {
            appState.showError(error.localizedDescription)
        }
    }

    @MainActor
    private func handleSingleVersionReformat(capturedText: String, mode: Mode, appState: AppState) async {
        do {
            appState.statusMessage = "Reformatting..."

            let reformattedText = try await LLMServiceCoordinator.shared.reformat(
                text: capturedText,
                using: mode,
                knowledgeContext: appState.knowledgeContext
            )

            appState.statusMessage = "Replacing text..."

            // Store for undo before replacing
            appState.storeForUndo(original: capturedText, replacement: reformattedText)

            // Replace the original text
            try await TextCaptureService.shared.replaceSelectedText(with: reformattedText)

            appState.showSuccess("Text reformatted!")
        } catch {
            appState.showError(error.localizedDescription)
        }
    }

    @MainActor
    private func handleMultiVersionReformat(capturedText: String, mode: Mode, appState: AppState) async {
        do {
            appState.statusMessage = "Generating \(appState.numberOfVersions) versions..."

            // Generate multiple versions in parallel
            let versions = try await withThrowingTaskGroup(of: String.self) { group in
                for _ in 0..<appState.numberOfVersions {
                    group.addTask {
                        try await LLMServiceCoordinator.shared.reformat(
                            text: capturedText,
                            using: mode,
                            knowledgeContext: appState.knowledgeContext
                        )
                    }
                }

                var results: [String] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }

            appState.isProcessing = false

            // Show version picker
            VersionPickerWindowController.shared.show(
                versions: versions,
                originalText: capturedText
            ) { [weak self] selectedVersion in
                guard let selectedVersion = selectedVersion else {
                    appState.statusMessage = "Ready"
                    return
                }

                Task { @MainActor in
                    do {
                        appState.statusMessage = "Replacing text..."

                        // Store for undo before replacing
                        appState.storeForUndo(original: capturedText, replacement: selectedVersion)

                        try await TextCaptureService.shared.replaceSelectedText(with: selectedVersion)
                        appState.showSuccess("Text reformatted!")
                    } catch {
                        appState.showError(error.localizedDescription)
                    }
                }
            }

        } catch {
            appState.showError(error.localizedDescription)
        }
    }

    private func requestAccessibilityPermissions() {
        _ = AccessibilityService.requestPermissions()
    }
}
