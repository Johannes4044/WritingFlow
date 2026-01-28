import SwiftUI
import AppKit
import Combine

struct VersionOption: Identifiable {
    let id = UUID()
    let content: String
    let index: Int
}

struct VersionPickerPanel: View {
    let versions: [VersionOption]
    let originalText: String
    let onSelect: (String) -> Void
    let onCancel: () -> Void

    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "doc.on.doc")
                    .foregroundColor(WritingFlowColors.primaryAccent)
                Text("Choose Version")
                    .font(.headline)
                Spacer()
                Text("\(versions.count) versions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Original text (collapsed)
            DisclosureGroup {
                Text(originalText)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            } label: {
                HStack {
                    Image(systemName: "text.quote")
                        .foregroundColor(.secondary)
                    Text("Original")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Versions list
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(versions.enumerated()), id: \.element.id) { index, version in
                            VersionRow(
                                version: version,
                                isSelected: index == selectedIndex,
                                onSelect: {
                                    selectVersion(version)
                                }
                            )
                            .id(index)
                        }
                    }
                    .padding()
                }
                .onChange(of: selectedIndex) { _, newIndex in
                    withAnimation(.easeOut(duration: 0.1)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }

            Divider()

            // Footer
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.escape, modifiers: [])

                Spacer()

                HStack(spacing: 4) {
                    Text("↑↓").fontWeight(.medium)
                    Text("Navigate")
                    Text("  ")
                    Text("⏎").fontWeight(.medium)
                    Text("Select")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                Spacer()

                Button("Use Selected") {
                    selectVersion(versions[selectedIndex])
                }
                .keyboardShortcut(.return, modifiers: [])
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 500, height: 600)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        .background(VersionKeyboardHandler(
            onUp: { moveSelection(by: -1) },
            onDown: { moveSelection(by: 1) },
            onEnter: { selectVersion(versions[selectedIndex]) },
            onEscape: { onCancel() }
        ))
    }

    private func moveSelection(by offset: Int) {
        let newIndex = selectedIndex + offset
        if newIndex >= 0 && newIndex < versions.count {
            selectedIndex = newIndex
        }
    }

    private func selectVersion(_ version: VersionOption) {
        onSelect(version.content)
    }
}

struct VersionRow: View {
    let version: VersionOption
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var isHovering = false
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(isSelected ? WritingFlowColors.primaryAccent : Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("\(version.index + 1)")
                            .font(.caption.bold())
                            .foregroundColor(isSelected ? .white : .secondary)
                    )

                Text("Version \(version.index + 1)")
                    .font(.subheadline.weight(.medium))

                Spacer()

                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            if isExpanded {
                Text(version.content)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
            } else {
                Text(version.content.prefix(150) + (version.content.count > 150 ? "..." : ""))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? WritingFlowColors.primaryAccent.opacity(0.1) : (isHovering ? Color.gray.opacity(0.05) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? WritingFlowColors.primaryAccent : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { onSelect() }
        .onTapGesture(count: 1) { isExpanded.toggle() }
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// Keyboard handler for version picker
struct VersionKeyboardHandler: NSViewRepresentable {
    let onUp: () -> Void
    let onDown: () -> Void
    let onEnter: () -> Void
    let onEscape: () -> Void

    func makeNSView(context: Context) -> VersionKeyboardView {
        let view = VersionKeyboardView()
        view.onUp = onUp
        view.onDown = onDown
        view.onEnter = onEnter
        view.onEscape = onEscape
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: VersionKeyboardView, context: Context) {
        nsView.onUp = onUp
        nsView.onDown = onDown
        nsView.onEnter = onEnter
        nsView.onEscape = onEscape
    }
}

class VersionKeyboardView: NSView {
    var onUp: (() -> Void)?
    var onDown: (() -> Void)?
    var onEnter: (() -> Void)?
    var onEscape: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case KeyCode.upArrow: onUp?()
        case KeyCode.downArrow: onDown?()
        case KeyCode.enter: onEnter?()
        case KeyCode.escape: onEscape?()
        default: super.keyDown(with: event)
        }
    }
}

// Window controller for the version picker
class VersionPickerWindowController: NSObject, ObservableObject {
    static let shared = VersionPickerWindowController()

    private var window: NSWindow?
    private var completion: ((String?) -> Void)?

    func show(versions: [String], originalText: String, completion: @escaping (String?) -> Void) {
        self.completion = completion

        let versionOptions = versions.enumerated().map { VersionOption(content: $1, index: $0) }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true

        let contentView = VersionPickerPanel(
            versions: versionOptions,
            originalText: originalText,
            onSelect: { [weak self] selected in
                self?.completion?(selected)
                self?.hide()
            },
            onCancel: { [weak self] in
                self?.completion?(nil)
                self?.hide()
            }
        )

        panel.contentView = NSHostingView(rootView: contentView)
        panel.center()

        window = panel
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        window?.orderOut(nil)
        window = nil
        completion = nil
    }
}
