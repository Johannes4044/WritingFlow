import SwiftUI

// MARK: - Key Codes

enum KeyCode {
    static let upArrow = 126
    static let downArrow = 125
    static let enter = 36
    static let escape = 53
    static let delete = 51
    static let tab = 48
    static let space = 49
}

// MARK: - Colors

enum WritingFlowColors {
    // Primary brand colors (vibrant accents)
    static let primaryAccent = Color(hex: "#6366F1")   // Indigo
    static let secondaryAccent = Color(hex: "#EC4899") // Pink
    static let tertiaryAccent = Color(hex: "#14B8A6")  // Teal

    // Semantic colors
    static let success = Color(hex: "#22C55E")
    static let warning = Color(hex: "#F59E0B")
    static let error = Color(hex: "#EF4444")

    // Background colors
    static let cardBackground = Color(nsColor: .controlBackgroundColor)
    static let hoverBackground = Color.gray.opacity(0.1)

    // Mode colors
    static let email = Color(hex: "#3B82F6")
    static let whatsapp = Color(hex: "#22C55E")
    static let formal = Color(hex: "#6366F1")
    static let casual = Color(hex: "#F59E0B")
    static let grammarFix = Color(hex: "#14B8A6")
}

// MARK: - Spacing

enum WritingFlowSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Corner Radius

enum WritingFlowRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 6
    static let md: CGFloat = 10
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
}

// MARK: - Animations

extension Animation {
    static let writingFlowSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let writingFlowBounce = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let writingFlowEaseOut = Animation.easeOut(duration: 0.2)
    static let writingFlowSmooth = Animation.easeInOut(duration: 0.25)
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        guard let components = NSColor(self).cgColor.components else { return "#000000" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(WritingFlowColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: WritingFlowRadius.md))
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

struct VibrantButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, WritingFlowSpacing.md)
            .padding(.vertical, WritingFlowSpacing.sm)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: WritingFlowRadius.sm))
            .shadow(color: color.opacity(0.3), radius: configuration.isPressed ? 2 : 4, y: configuration.isPressed ? 1 : 2)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.writingFlowSpring, value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    func vibrantButton(color: Color = WritingFlowColors.primaryAccent) -> some View {
        buttonStyle(VibrantButtonStyle(color: color))
    }
}

// MARK: - Processing Indicator

struct ProcessingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                AngularGradient(
                    colors: [WritingFlowColors.primaryAccent, WritingFlowColors.secondaryAccent, WritingFlowColors.tertiaryAccent],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: 24, height: 24)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear { isAnimating = true }
    }
}

// MARK: - Toast View

struct ToastView: View {
    let message: String
    let type: AppState.NotificationType

    var body: some View {
        HStack(spacing: WritingFlowSpacing.sm) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)

            Text(message)
                .font(.system(size: 13, weight: .medium))
        }
        .padding(.horizontal, WritingFlowSpacing.md)
        .padding(.vertical, WritingFlowSpacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }

    private var iconName: String {
        switch type {
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    private var iconColor: Color {
        switch type {
        case .success: return WritingFlowColors.success
        case .error: return WritingFlowColors.error
        case .info: return WritingFlowColors.primaryAccent
        }
    }
}
