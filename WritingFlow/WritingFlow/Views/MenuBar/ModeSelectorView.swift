import SwiftUI

struct ModeSelectorView: View {
    let modes: [Mode]
    @Binding var selectedMode: Mode?

    var body: some View {
        VStack(spacing: WritingFlowSpacing.sm) {
            ForEach(modes) { mode in
                ModeRowView(
                    mode: mode,
                    isSelected: selectedMode?.id == mode.id,
                    onSelect: { selectedMode = mode }
                )
            }
        }
    }
}

struct ModeRowView: View {
    let mode: Mode
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: WritingFlowSpacing.md) {
                // Mode icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [mode.color, mode.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                        .shadow(color: mode.color.opacity(0.3), radius: isSelected ? 6 : 3, y: isSelected ? 3 : 1)

                    Image(systemName: mode.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .scaleEffect(isSelected ? 1.05 : 1)

                // Mode name
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.name)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(.primary)

                    if isSelected {
                        Text("Active")
                            .font(.system(size: 10))
                            .foregroundColor(mode.color)
                    }
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(mode.color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(WritingFlowSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: WritingFlowRadius.md)
                    .fill(isSelected ? mode.color.opacity(0.1) : (isHovering ? WritingFlowColors.hoverBackground : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: WritingFlowRadius.md)
                    .stroke(isSelected ? mode.color.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.writingFlowSpring, value: isSelected)
        .animation(.writingFlowEaseOut, value: isHovering)
    }
}
