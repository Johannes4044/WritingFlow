import SwiftUI
import SwiftData
import KeyboardShortcuts

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Mode.order) private var modes: [Mode]
    @Query private var abbreviations: [Abbreviation]
    @Query private var names: [NameEntry]

    @State private var isHoveringSettings = false
    @State private var isHoveringQuit = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Mode selector
            ScrollView {
                ModeSelectorView(
                    modes: modes,
                    selectedMode: $appState.currentMode
                )
                .padding(WritingFlowSpacing.md)
            }
            .frame(maxHeight: 280)

            Divider()

            // Footer
            footerView
        }
        .frame(width: 280)
        .background(.ultraThinMaterial)
        .onAppear {
            initializeDefaultsIfNeeded()
            updateKnowledgeContext()
            syncModesToAppState()
        }
        .onChange(of: modes) { _, _ in syncModesToAppState() }
        .onChange(of: abbreviations) { _, _ in updateKnowledgeContext() }
        .onChange(of: names) { _, _ in updateKnowledgeContext() }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Writing Flow")
                    .font(.system(size: 14, weight: .semibold))

                Text(appState.statusMessage)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if appState.isProcessing {
                ProcessingIndicator()
            } else if appState.showNotification {
                ToastView(
                    message: appState.notificationMessage,
                    type: appState.notificationType
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(WritingFlowSpacing.md)
        .animation(.writingFlowSpring, value: appState.isProcessing)
        .animation(.writingFlowSpring, value: appState.showNotification)
    }

    private var footerView: some View {
        HStack {
            SettingsLink {
                HStack(spacing: WritingFlowSpacing.xs) {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .font(.system(size: 12))
                .foregroundColor(isHoveringSettings ? WritingFlowColors.primaryAccent : .primary)
            }
            .buttonStyle(.plain)
            .onHover { isHoveringSettings = $0 }
            .simultaneousGesture(TapGesture().onEnded {
                NSApp.activate(ignoringOtherApps: true)
            })

            Spacer()

            // Accessibility status indicator
            if !AccessibilityService.hasPermissions {
                Button(action: requestAccessibility) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(WritingFlowColors.warning)
                        Text("Grant Access")
                            .font(.system(size: 10))
                    }
                }
                .buttonStyle(.plain)
            } else if let shortcut = KeyboardShortcuts.getShortcut(for: .captureAndReformat) {
                // Show current hotkey
                Text(shortcut.description)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            Spacer()

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Text("Quit")
                    .font(.system(size: 12))
                    .foregroundColor(isHoveringQuit ? WritingFlowColors.error : .primary)
            }
            .buttonStyle(.plain)
            .onHover { isHoveringQuit = $0 }
        }
        .padding(WritingFlowSpacing.md)
    }

    private func requestAccessibility() {
        _ = AccessibilityService.requestPermissions()
    }

    private func initializeDefaultsIfNeeded() {
        // Add default modes if none exist
        if modes.isEmpty {
            for mode in Mode.defaultModes {
                modelContext.insert(mode)
            }
            try? modelContext.save()
        }

        // Set current mode if not set
        if appState.currentMode == nil {
            appState.currentMode = modes.first(where: { $0.isDefault }) ?? modes.first
        }

        // Add default abbreviations if none exist
        if abbreviations.isEmpty {
            for abbrev in Abbreviation.defaultAbbreviations {
                modelContext.insert(abbrev)
            }
            try? modelContext.save()
        }
    }

    private func updateKnowledgeContext() {
        appState.updateKnowledgeContext(abbreviations: abbreviations, names: names)
    }

    private func syncModesToAppState() {
        appState.availableModes = modes
        // Register mode-specific hotkeys
        HotkeyService.shared.registerModeHotkeys(modes: modes)
    }
}
