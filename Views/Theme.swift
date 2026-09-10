import SwiftUI

struct Theme {
    // MARK: - Color Palette
    // Deep space backgrounds
    static let backgroundStart   = Color(red: 0.04, green: 0.04, blue: 0.12)
    static let backgroundMid     = Color(red: 0.07, green: 0.06, blue: 0.20)
    static let backgroundEnd     = Color(red: 0.10, green: 0.06, blue: 0.26)

    // Card surfaces — frosted glass feel
    static let cardBackground    = Color(red: 0.12, green: 0.11, blue: 0.22)
    static let cardBorder        = Color.white.opacity(0.10)
    static let cardBorderStrong  = Color.white.opacity(0.18)

    // Electric violet accent
    static let primaryAccent     = Color(red: 0.45, green: 0.22, blue: 1.00)
    // Neon cyan accent
    static let secondaryAccent   = Color(red: 0.10, green: 0.82, blue: 0.95)
    // Rose for negative / delete
    static let dangerColor       = Color(red: 0.95, green: 0.30, blue: 0.52)
    // Mint green for positive / settled
    static let successColor      = Color(red: 0.18, green: 0.88, blue: 0.62)
    // Warm gold for currency/logout
    static let warmGold          = Color(red: 1.0, green: 0.65, blue: 0.15)

    // Chip (tag) colors
    static let chipBackground    = Color(red: 0.45, green: 0.22, blue: 1.00).opacity(0.18)
    static let chipText          = Color(red: 0.80, green: 0.70, blue: 1.00)

    // MARK: - Gradients
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundStart, backgroundMid, backgroundEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryAccent, secondaryAccent.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var roseGradient: LinearGradient {
        LinearGradient(
            colors: [dangerColor, Color(red: 1.0, green: 0.55, blue: 0.30)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var mintGradient: LinearGradient {
        LinearGradient(
            colors: [successColor, Color(red: 0.10, green: 0.82, blue: 0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Legacy helpers (kept for compatibility — prefer .glassCard() / .accentCard() modifiers)
    static func applyGlassCard(to view: AnyView, cornerRadius: CGFloat = 20) -> some View {
        view.glassCard(cornerRadius: cornerRadius)
    }

    static func applyAccentCard(to view: AnyView, cornerRadius: CGFloat = 28) -> some View {
        view.accentCard(cornerRadius: cornerRadius)
    }

    /// Glow shadow helper
    static func glowShadow(_ color: Color = primaryAccent, radius: CGFloat = 18) -> some View {
        Circle()
            .fill(color.opacity(0.25))
            .blur(radius: radius)
    }
}

// MARK: - Glass Card Modifier
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(Theme.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
    }
}

// MARK: - Accent Card Modifier
struct AccentCardModifier: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Theme.primaryAccent.opacity(0.35), Theme.secondaryAccent.opacity(0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(cornerRadius)
            .shadow(color: Theme.primaryAccent.opacity(0.20), radius: 15, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.cardBorderStrong, lineWidth: 1)
            )
    }
}

// MARK: - Pressable Button Style
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }

    func accentCard(cornerRadius: CGFloat = 28) -> some View {
        modifier(AccentCardModifier(cornerRadius: cornerRadius))
    }

    @ViewBuilder
    func halfSheetIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents([.medium, .large])
        } else {
            self
        }
    }
}

// MARK: - Reusable Stat Badge
struct StatBadge: View {
    var icon: String
    var label: String
    var value: String
    var color: Color = Theme.primaryAccent

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundColor(color)
            Text(value)
                .font(.title3.weight(.heavy))
                .foregroundColor(.white)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Gradient Avatar
struct GradientAvatar: View {
    var name: String
    var size: CGFloat = 50
    var gradient: LinearGradient = Theme.primaryGradient

    var body: some View {
        ZStack {
            Circle()
                .fill(gradient)
                .frame(width: size, height: size)
                .shadow(color: Theme.primaryAccent.opacity(0.20), radius: 8, x: 0, y: 4)
            Text(name.prefix(1).uppercased())
                .font(.headline.weight(.heavy))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    var title: String
    var trailing: AnyView? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
            Spacer()
            if let trailing = trailing {
                trailing
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Drag Handle
struct DragHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white.opacity(0.3))
            .frame(width: 38, height: 5)
            .padding(.top, 14)
    }
}

// MARK: - Sheet Header Bar
struct SheetHeader: View {
    var title: String
    var leadingLabel: String = "Cancel"
    var trailingLabel: String
    var trailingEnabled: Bool = true
    var trailingColor: Color = Theme.secondaryAccent
    var onLeading: () -> Void
    var onTrailing: () -> Void

    var body: some View {
        HStack {
            Button(leadingLabel, action: onLeading)
                .foregroundColor(.white.opacity(0.6))
                .font(.headline)
            Spacer()
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
            Spacer()
            Button(trailingLabel, action: onTrailing)
                .font(.headline.weight(.bold))
                .foregroundColor(trailingEnabled ? trailingColor : Color.white.opacity(0.3))
                .disabled(!trailingEnabled)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
    }
}

// MARK: - Icon Badge (round icon container)
struct IconBadge: View {
    var systemName: String
    var color: Color
    var size: CGFloat = 38
    var iconSize: CGFloat = 15

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
                .fill(color.opacity(0.15))
                .frame(width: size, height: size)
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Gradient Primary Button
struct GradientButton: View {
    var label: String
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isEnabled ? AnyView(Theme.primaryGradient) : AnyView(Color.white.opacity(0.10))
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: isEnabled ? Theme.primaryAccent.opacity(0.45) : .clear, radius: 12, x: 0, y: 6)
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}
