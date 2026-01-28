import Foundation
import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    // Main reformat hotkey
    static let captureAndReformat = Self(
        "captureAndReformat",
        default: .init(.r, modifiers: [.command, .shift])
    )

    // Cycle through modes hotkey
    static let cycleMode = Self(
        "cycleMode",
        default: .init(.m, modifiers: [.command, .control])
    )

    // Revert last change hotkey
    static let revertLastChange = Self(
        "revertLastChange",
        default: .init(.z, modifiers: [.command, .shift])
    )
}

class HotkeyService {
    static let shared = HotkeyService()

    private var onCaptureAndReformat: (() -> Void)?
    private var onCycleMode: (() -> Void)?
    private var onRevertLastChange: (() -> Void)?
    private var onModeSwitch: ((Mode) -> Void)?

    // Global monitor for mode-specific hotkeys
    private var modeHotkeyMonitor: Any?
    private var registeredModes: [Mode] = []

    private init() {}

    func setup(
        onCaptureAndReformat: @escaping () -> Void,
        onCycleMode: @escaping () -> Void,
        onRevertLastChange: @escaping () -> Void = {},
        onModeSwitch: @escaping (Mode) -> Void = { _ in }
    ) {
        self.onCaptureAndReformat = onCaptureAndReformat
        self.onCycleMode = onCycleMode
        self.onRevertLastChange = onRevertLastChange
        self.onModeSwitch = onModeSwitch

        KeyboardShortcuts.onKeyUp(for: .captureAndReformat) { [weak self] in
            self?.onCaptureAndReformat?()
        }

        KeyboardShortcuts.onKeyUp(for: .cycleMode) { [weak self] in
            self?.onCycleMode?()
        }

        KeyboardShortcuts.onKeyUp(for: .revertLastChange) { [weak self] in
            self?.onRevertLastChange?()
        }
    }

    // Register mode-specific hotkeys
    func registerModeHotkeys(modes: [Mode]) {
        // Remove existing monitor
        if let monitor = modeHotkeyMonitor {
            NSEvent.removeMonitor(monitor)
            modeHotkeyMonitor = nil
        }

        // Filter modes that have hotkeys
        registeredModes = modes.filter { $0.hasHotkey }

        guard !registeredModes.isEmpty else { return }

        // Add global monitor for mode hotkeys
        modeHotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleModeHotkey(event: event)
        }
    }

    private func handleModeHotkey(event: NSEvent) {
        let keyCode = Int(event.keyCode)
        let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift]).rawValue

        for mode in registeredModes {
            if let modeKeyCode = mode.hotkeyKeyCode,
               let modeModifiers = mode.hotkeyModifiers,
               keyCode == modeKeyCode,
               UInt(modeModifiers) == modifiers {
                Task { @MainActor in
                    self.onModeSwitch?(mode)
                }
                break
            }
        }
    }

    func disableAll() {
        KeyboardShortcuts.disable(.captureAndReformat)
        KeyboardShortcuts.disable(.cycleMode)
        KeyboardShortcuts.disable(.revertLastChange)

        if let monitor = modeHotkeyMonitor {
            NSEvent.removeMonitor(monitor)
            modeHotkeyMonitor = nil
        }
    }

    func enableAll() {
        KeyboardShortcuts.enable(.captureAndReformat)
        KeyboardShortcuts.enable(.cycleMode)
        KeyboardShortcuts.enable(.revertLastChange)

        // Re-register mode hotkeys if there were modes registered
        if !registeredModes.isEmpty {
            registerModeHotkeys(modes: registeredModes)
        }
    }
}
