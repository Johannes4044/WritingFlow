import SwiftData
import SwiftUI
import Foundation

@Model
final class Mode {
    var id: UUID
    var name: String
    var systemPrompt: String
    var iconName: String
    var colorHex: String
    var order: Int
    var isDefault: Bool
    var createdAt: Date
    var updatedAt: Date

    // Hotkey properties (stored as raw values for persistence)
    var hotkeyKeyCode: Int?
    var hotkeyModifiers: Int?

    init(
        name: String,
        systemPrompt: String,
        iconName: String = "text.bubble",
        colorHex: String = "#6366F1",
        order: Int = 0,
        isDefault: Bool = false,
        hotkeyKeyCode: Int? = nil,
        hotkeyModifiers: Int? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.systemPrompt = systemPrompt
        self.iconName = iconName
        self.colorHex = colorHex
        self.order = order
        self.isDefault = isDefault
        self.hotkeyKeyCode = hotkeyKeyCode
        self.hotkeyModifiers = hotkeyModifiers
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var hasHotkey: Bool {
        hotkeyKeyCode != nil
    }

    var color: Color {
        Color(hex: colorHex)
    }

    static var defaultModes: [Mode] {
        [
            Mode(
                name: "Email",
                systemPrompt: "Reformat the following text as a professional email. Maintain a polite and clear tone. Expand any abbreviations. Ensure proper greeting and sign-off if appropriate. Return ONLY the reformatted text.",
                iconName: "envelope.fill",
                colorHex: "#3B82F6",
                order: 0,
                isDefault: true
            ),
            Mode(
                name: "WhatsApp",
                systemPrompt: "Reformat the following text for WhatsApp messaging. Keep it casual and friendly. Use appropriate emoji where natural. Keep it concise. Return ONLY the reformatted text.",
                iconName: "message.fill",
                colorHex: "#22C55E",
                order: 1
            ),
            Mode(
                name: "Formal",
                systemPrompt: "Reformat the following text in a formal, professional tone. Use proper grammar and vocabulary. Avoid contractions and colloquialisms. Return ONLY the reformatted text.",
                iconName: "building.2.fill",
                colorHex: "#6366F1",
                order: 2
            ),
            Mode(
                name: "Casual",
                systemPrompt: "Reformat the following text in a casual, friendly tone. Make it sound natural and conversational. Return ONLY the reformatted text.",
                iconName: "face.smiling.fill",
                colorHex: "#F59E0B",
                order: 3
            ),
            Mode(
                name: "Grammar Fix",
                systemPrompt: "Fix any grammar, spelling, and punctuation errors in the following text. Keep the original meaning and tone intact. Return ONLY the corrected text.",
                iconName: "checkmark.circle.fill",
                colorHex: "#14B8A6",
                order: 4
            )
        ]
    }
}
