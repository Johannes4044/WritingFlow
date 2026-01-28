import SwiftUI
import KeyboardShortcuts

struct HotkeySettingsView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Capture & Reformat")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .captureAndReformat)
                }
            } header: {
                Text("Global Hotkey")
            } footer: {
                Text("Press this keyboard shortcut anywhere to capture selected text and reformat it using the current mode.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    InstructionRow(
                        number: 1,
                        title: "Select text",
                        description: "Highlight the text you want to reformat in any application"
                    )

                    InstructionRow(
                        number: 2,
                        title: "Press the hotkey",
                        description: "Use your configured keyboard shortcut"
                    )

                    InstructionRow(
                        number: 3,
                        title: "Text is reformatted",
                        description: "The selected text is replaced with the reformatted version"
                    )
                }
                .padding(.vertical, 8)
            } header: {
                Text("How it works")
            }

            Section {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(WritingFlowColors.warning)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Accessibility Required")
                            .font(.system(size: 13, weight: .medium))

                        Text("Writing Flow needs accessibility permissions to capture and replace text. Grant access in System Settings > Privacy & Security > Accessibility.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct InstructionRow: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(WritingFlowColors.primaryAccent)
                    .frame(width: 28, height: 28)

                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}
