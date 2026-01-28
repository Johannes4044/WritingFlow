import SwiftUI
import ServiceManagement
import KeyboardShortcuts

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showProcessingOverlay") private var showProcessingOverlay = true
    @AppStorage("playSound") private var playSound = true
    @AppStorage("autoReplaceText") private var autoReplaceText = true

    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(newValue)
                    }
            } header: {
                Text("Startup")
            }

            Section {
                Toggle("Auto-replace selected text", isOn: $autoReplaceText)
                Text("When enabled, the reformatted text will automatically replace your selection. When disabled, it will be copied to clipboard.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Behavior")
            }

            // Multiple Versions Section
            Section {
                Toggle("Generate Multiple Versions", isOn: $appState.enableMultipleVersions)

                if appState.enableMultipleVersions {
                    Stepper(value: $appState.numberOfVersions, in: 2...5) {
                        HStack {
                            Text("Number of versions")
                            Spacer()
                            Text("\(appState.numberOfVersions)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                Text("Multiple Versions")
            } footer: {
                Text("When enabled, generates multiple reformatted versions for you to choose from")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Hotkeys Section
            Section {
                HStack {
                    Text("Reformat Text")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .captureAndReformat)
                }

                HStack {
                    Text("Cycle Mode")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .cycleMode)
                }
            } header: {
                Text("Keyboard Shortcuts")
            }

            Section {
                Toggle("Show processing indicator", isOn: $showProcessingOverlay)
                Toggle("Play sound on completion", isOn: $playSound)
            } header: {
                Text("Feedback")
            }

            Section {
                HStack {
                    Text("Accessibility Status")
                    Spacer()
                    if AccessibilityService.hasPermissions {
                        Label("Granted", systemImage: "checkmark.circle.fill")
                            .foregroundColor(WritingFlowColors.success)
                    } else {
                        Label("Not Granted", systemImage: "exclamationmark.circle.fill")
                            .foregroundColor(WritingFlowColors.error)
                    }
                }

                if !AccessibilityService.hasPermissions {
                    Button("Open Accessibility Settings") {
                        AccessibilityService.openAccessibilitySettings()
                    }
                    .vibrantButton(color: WritingFlowColors.primaryAccent)

                    Text("Accessibility access is required to capture and replace selected text.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Permissions")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            #if DEBUG
            print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            #endif
        }
    }
}
