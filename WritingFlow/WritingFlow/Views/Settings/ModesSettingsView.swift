import SwiftUI
import SwiftData
import AppKit

struct ModesSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Mode.order) private var modes: [Mode]

    @State private var selectedMode: Mode?
    @State private var isAddingMode = false
    @State private var isEditingMode = false

    var body: some View {
        HSplitView {
            // Mode list
            VStack(spacing: 0) {
                List(selection: $selectedMode) {
                    ForEach(modes) { mode in
                        ModeListRow(mode: mode)
                            .tag(mode)
                    }
                    .onMove(perform: moveMode)
                    .onDelete(perform: deleteMode)
                }
                .listStyle(.inset)

                Divider()

                // Toolbar
                HStack {
                    Button(action: { isAddingMode = true }) {
                        Image(systemName: "plus")
                    }

                    Button(action: deleteSelectedMode) {
                        Image(systemName: "minus")
                    }
                    .disabled(selectedMode == nil)

                    Spacer()
                }
                .padding(8)
            }
            .frame(minWidth: 180, maxWidth: 220)

            // Mode editor
            if let mode = selectedMode {
                ModeEditorView(mode: mode)
            } else {
                VStack {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Select a mode to edit")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $isAddingMode) {
            AddModeSheet(isPresented: $isAddingMode)
        }
    }

    private func moveMode(from source: IndexSet, to destination: Int) {
        var modeArray = modes
        modeArray.move(fromOffsets: source, toOffset: destination)

        for (index, mode) in modeArray.enumerated() {
            mode.order = index
        }
        try? modelContext.save()
    }

    private func deleteMode(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(modes[index])
        }
        try? modelContext.save()
    }

    private func deleteSelectedMode() {
        if let mode = selectedMode {
            modelContext.delete(mode)
            selectedMode = nil
            try? modelContext.save()
        }
    }
}

struct ModeListRow: View {
    let mode: Mode

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(mode.color)
                .frame(width: 12, height: 12)

            Text(mode.name)
                .lineLimit(1)

            if mode.isDefault {
                Text("Default")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }
}

struct ModeEditorView: View {
    @Bindable var mode: Mode
    @Environment(\.modelContext) private var modelContext

    let iconOptions = [
        "text.bubble", "envelope.fill", "message.fill", "building.2.fill",
        "face.smiling.fill", "checkmark.circle.fill", "pencil", "doc.text",
        "person.fill", "briefcase.fill", "star.fill", "heart.fill"
    ]

    let colorOptions = [
        "#3B82F6", "#22C55E", "#6366F1", "#F59E0B",
        "#14B8A6", "#EC4899", "#EF4444", "#8B5CF6"
    ]

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $mode.name)
                    .textFieldStyle(.roundedBorder)

                Toggle("Set as default", isOn: $mode.isDefault)
                    .onChange(of: mode.isDefault) { _, newValue in
                        if newValue {
                            clearOtherDefaults()
                        }
                    }
            } header: {
                Text("Basic Info")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Icon")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(32)), count: 6), spacing: 8) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button(action: { mode.iconName = icon }) {
                                Image(systemName: icon)
                                    .font(.system(size: 16))
                                    .frame(width: 28, height: 28)
                                    .background(mode.iconName == icon ? mode.color.opacity(0.2) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Color")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        ForEach(colorOptions, id: \.self) { colorHex in
                            Button(action: { mode.colorHex = colorHex }) {
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: mode.colorHex == colorHex ? 2 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } header: {
                Text("Appearance")
            }

            Section {
                HStack {
                    Text("Hotkey")
                    Spacer()
                    ModeHotkeyRecorder(
                        keyCode: Binding(
                            get: { mode.hotkeyKeyCode },
                            set: { mode.hotkeyKeyCode = $0; saveChanges() }
                        ),
                        modifiers: Binding(
                            get: { mode.hotkeyModifiers },
                            set: { mode.hotkeyModifiers = $0; saveChanges() }
                        )
                    )
                }
            } header: {
                Text("Quick Switch")
            } footer: {
                Text("Assign a keyboard shortcut to quickly switch to this mode from anywhere.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                TextEditor(text: $mode.systemPrompt)
                    .font(.system(size: 12, design: .monospaced))
                    .frame(minHeight: 150)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } header: {
                Text("System Prompt")
            } footer: {
                Text("This prompt tells the LLM how to reformat text. Be specific about the desired tone and style.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .onChange(of: mode.name) { _, _ in saveChanges() }
        .onChange(of: mode.systemPrompt) { _, _ in saveChanges() }
        .onChange(of: mode.iconName) { _, _ in saveChanges() }
        .onChange(of: mode.colorHex) { _, _ in saveChanges() }
    }

    private func saveChanges() {
        mode.updatedAt = Date()
        do {
            try modelContext.save()
        } catch {
            #if DEBUG
            print("Failed to save mode changes: \(error)")
            #endif
        }
    }

    private func clearOtherDefaults() {
        let descriptor = FetchDescriptor<Mode>()
        if let allModes = try? modelContext.fetch(descriptor) {
            for otherMode in allModes where otherMode.id != mode.id {
                otherMode.isDefault = false
            }
        }
        try? modelContext.save()
    }
}

struct AddModeSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var systemPrompt = "Reformat the following text. Return ONLY the reformatted text."

    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Mode")
                .font(.headline)

            TextField("Mode Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $systemPrompt)
                .font(.system(size: 12, design: .monospaced))
                .frame(height: 100)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack {
                Button("Cancel") {
                    isPresented = false
                }

                Spacer()

                Button("Add Mode") {
                    addMode()
                }
                .vibrantButton()
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }

    private func addMode() {
        let descriptor = FetchDescriptor<Mode>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0

        let newMode = Mode(
            name: name,
            systemPrompt: systemPrompt,
            order: count
        )
        modelContext.insert(newMode)
        try? modelContext.save()
        isPresented = false
    }
}

// MARK: - Mode Hotkey Recorder

struct ModeHotkeyRecorder: View {
    @Binding var keyCode: Int?
    @Binding var modifiers: Int?

    @State private var isRecording = false

    var body: some View {
        HStack(spacing: 8) {
            if let keyCode = keyCode, let modifiers = modifiers {
                Text(hotkeyDescription(keyCode: keyCode, modifiers: modifiers))
                    .font(.system(size: 12, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Button(action: clearHotkey) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            } else {
                Text(isRecording ? "Press shortcut..." : "None")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isRecording ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            if !isRecording {
                Button(keyCode != nil ? "Change" : "Record") {
                    isRecording = true
                }
                .buttonStyle(.bordered)
            } else {
                Button("Cancel") {
                    isRecording = false
                }
                .buttonStyle(.bordered)
            }
        }
        .background(
            HotkeyRecorderKeyHandler(
                isRecording: $isRecording,
                onRecord: { code, mods in
                    keyCode = code
                    modifiers = mods
                    isRecording = false
                }
            )
        )
    }

    private func clearHotkey() {
        keyCode = nil
        modifiers = nil
    }

    private func hotkeyDescription(keyCode: Int, modifiers: Int) -> String {
        var parts: [String] = []
        let mods = NSEvent.ModifierFlags(rawValue: UInt(modifiers))

        if mods.contains(.control) { parts.append("⌃") }
        if mods.contains(.option) { parts.append("⌥") }
        if mods.contains(.shift) { parts.append("⇧") }
        if mods.contains(.command) { parts.append("⌘") }

        let keyName = keyCodeToString(keyCode)
        parts.append(keyName)

        return parts.joined()
    }

    private func keyCodeToString(_ keyCode: Int) -> String {
        let keyMap: [Int: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 36: "↵",
            37: "L", 38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",",
            44: "/", 45: "N", 46: "M", 47: ".", 48: "⇥", 49: "Space",
            51: "⌫", 53: "⎋", 96: "F5", 97: "F6", 98: "F7", 99: "F3",
            100: "F8", 101: "F9", 103: "F11", 105: "F13", 107: "F14",
            109: "F10", 111: "F12", 113: "F15", 118: "F4", 119: "F2",
            120: "F1", 122: "F1", 123: "←", 124: "→", 125: "↓", 126: "↑"
        ]
        return keyMap[keyCode] ?? "?"
    }
}

// NSViewRepresentable to capture keyboard events
struct HotkeyRecorderKeyHandler: NSViewRepresentable {
    @Binding var isRecording: Bool
    let onRecord: (Int, Int) -> Void

    func makeNSView(context: Context) -> HotkeyRecorderView {
        let view = HotkeyRecorderView()
        view.onRecord = onRecord
        return view
    }

    func updateNSView(_ nsView: HotkeyRecorderView, context: Context) {
        nsView.isRecording = isRecording
        nsView.onRecord = onRecord
        if isRecording {
            DispatchQueue.main.async {
                nsView.window?.makeFirstResponder(nsView)
            }
        }
    }
}

class HotkeyRecorderView: NSView {
    var isRecording = false
    var onRecord: ((Int, Int) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }

        // Require at least one modifier (Command, Option, or Control)
        let mods = event.modifierFlags.intersection([.command, .option, .control, .shift])
        guard mods.contains(.command) || mods.contains(.option) || mods.contains(.control) else {
            return
        }

        let keyCode = Int(event.keyCode)
        let modifiers = Int(mods.rawValue)

        onRecord?(keyCode, modifiers)
    }
}
