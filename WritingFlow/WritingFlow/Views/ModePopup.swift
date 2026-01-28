import SwiftUI
import AppKit

struct ModePopupView: View {
    let mode: Mode

    var body: some View {
        HStack(spacing: 12) {
            // Mode icon
            Image(systemName: mode.iconName)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: mode.colorHex))
                .frame(width: 40, height: 40)
                .background(Color(hex: mode.colorHex).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text("Mode")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(mode.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: mode.colorHex).opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
}

class ModePopupWindowController: NSObject {
    static let shared = ModePopupWindowController()

    private var window: NSWindow?
    private var hideWorkItem: DispatchWorkItem?

    func show(mode: Mode) {
        // Cancel any pending hide
        hideWorkItem?.cancel()

        // Close existing window
        window?.orderOut(nil)

        // Create content view
        let contentView = ModePopupView(mode: mode)

        // Create window
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 60),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary]

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = panel.contentView!.bounds
        panel.contentView = hostingView

        // Size to fit content
        let fittingSize = hostingView.fittingSize
        panel.setContentSize(fittingSize)

        // Position near the menu bar (below notch on MacBooks with notch)
        if let screen = NSScreen.main {
            // Use visibleFrame to account for notch and menu bar
            let visibleFrame = screen.visibleFrame

            let x = visibleFrame.midX - fittingSize.width / 2
            let y = visibleFrame.maxY - fittingSize.height - 10

            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        window = panel

        // Animate in
        panel.alphaValue = 0
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }

        // Schedule auto-hide
        let workItem = DispatchWorkItem { [weak self] in
            self?.hide()
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItem)
    }

    func hide() {
        guard let panel = window else { return }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.window?.orderOut(nil)
            self?.window = nil
        }
    }
}
