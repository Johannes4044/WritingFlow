import AppKit
import Carbon
import Combine

enum TextCaptureError: LocalizedError {
    case noPermissions
    case noTextCaptured
    case clipboardTimeout
    case replacementFailed

    var errorDescription: String? {
        switch self {
        case .noPermissions:
            return "Accessibility permissions required. Please enable in System Settings > Privacy & Security > Accessibility."
        case .noTextCaptured:
            return "No text was captured. Please select some text first."
        case .clipboardTimeout:
            return "Clipboard operation timed out. Please try again."
        case .replacementFailed:
            return "Failed to replace text."
        }
    }
}

@MainActor
class TextCaptureService: ObservableObject {
    static let shared = TextCaptureService()

    @Published var capturedText: String = ""
    @Published var isCapturing: Bool = false

    private let accessibilityService = AccessibilityService.shared
    private let pasteboard = NSPasteboard.general

    private init() {}

    func captureSelectedText() async throws -> String {
        guard AccessibilityService.hasPermissions else {
            throw TextCaptureError.noPermissions
        }

        isCapturing = true
        defer { isCapturing = false }

        // Small delay to let focus return to the source app after hotkey trigger
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Use Cmd+C clipboard method (most reliable across all apps)
        // The Accessibility API method rarely works as most apps don't expose selected text
        return try await captureViaClipboard()
    }

    private func captureViaClipboard() async throws -> String {
        // Get the frontmost app BEFORE we do anything - this is the app with selected text
        let frontmostApp = NSWorkspace.shared.frontmostApplication

        // Save current clipboard contents for restoration if capture fails
        let previousContents = pasteboard.string(forType: .string)

        // Clear clipboard FIRST, then save the changeCount
        // (clearContents increments changeCount, so we must save it AFTER clearing)
        pasteboard.clearContents()
        let changeCountAfterClear = pasteboard.changeCount

        // Re-activate the frontmost app to ensure Cmd+C goes to the right place
        frontmostApp?.activate()
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms for activation

        // Simulate Cmd+C
        simulateCopy()

        // Wait for clipboard to update (with timeout)
        // We're waiting for changeCount to be DIFFERENT from what it was after clearing
        var attempts = 0
        while pasteboard.changeCount == changeCountAfterClear && attempts < 30 {
            try await Task.sleep(nanoseconds: 100_000_000) // 100ms
            attempts += 1
        }

        // Check if we timed out waiting for clipboard
        let timedOut = pasteboard.changeCount == changeCountAfterClear

        // Get new clipboard content
        guard let text = pasteboard.string(forType: .string), !text.isEmpty else {
            // Restore previous clipboard
            if let previous = previousContents {
                pasteboard.clearContents()
                pasteboard.setString(previous, forType: .string)
            }
            throw timedOut ? TextCaptureError.clipboardTimeout : TextCaptureError.noTextCaptured
        }

        capturedText = text
        return text
    }

    func replaceSelectedText(with newText: String) async throws {
        // Method 1: Try direct accessibility replacement
        if accessibilityService.setSelectedText(newText) {
            return
        }

        // Method 2: Fallback to clipboard paste
        try await replaceViaClipboard(with: newText)
    }

    private func replaceViaClipboard(with newText: String) async throws {
        // Get the frontmost app to ensure paste goes to the right place
        let frontmostApp = NSWorkspace.shared.frontmostApplication

        // Copy new text to clipboard
        pasteboard.clearContents()
        pasteboard.setString(newText, forType: .string)

        // Re-activate the frontmost app
        frontmostApp?.activate()
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms for activation

        // Simulate Cmd+V
        simulatePaste()

        // Wait for paste to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
    }

    private func simulateCopy() {
        simulateKeyPress(keyCode: UInt16(kVK_ANSI_C), flags: .maskCommand)
    }

    private func simulatePaste() {
        simulateKeyPress(keyCode: UInt16(kVK_ANSI_V), flags: .maskCommand)
    }

    func simulateUndo() async {
        // Get the frontmost app to ensure undo goes to the right place
        let frontmostApp = NSWorkspace.shared.frontmostApplication
        frontmostApp?.activate()
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms for activation

        // Simulate Cmd+Z
        simulateKeyPress(keyCode: UInt16(kVK_ANSI_Z), flags: .maskCommand)
    }

    private func simulateKeyPress(keyCode: CGKeyCode, flags: CGEventFlags) {
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        keyDown?.flags = flags
        keyDown?.post(tap: .cghidEventTap)

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        keyUp?.flags = flags
        keyUp?.post(tap: .cghidEventTap)
    }
}
