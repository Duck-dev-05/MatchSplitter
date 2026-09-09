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

    // MARK: - Shadows
    static func glowShadow(_ color: Color = primaryAccent, radius: CGFloat = 18) -> some View {
        Circle()
            .fill(color.opacity(0.25))
            .blur(radius: radius)
    }

    // MARK: - Glass Card
    /// Wraps a view in a styled frosted-glass card with border and shadow.
    static func applyGlassCard(to view: AnyView, cornerRadius: CGFloat = 20) -> some View {
        view
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(cardBackground)
                    .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
                    .shadow(color: primaryAccent.opacity(0.08), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(cardBorder, lineWidth: 1)
            )
    }

    /// Glowing accent card (used for hero panels)
    static func applyAccentCard(to view: AnyView, cornerRadius: CGFloat = 28) -> some View {
        view
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [primaryAccent.opacity(0.35), secondaryAccent.opacity(0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: primaryAccent.opacity(0.30), radius: 24, x: 0, y: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(cardBorderStrong, lineWidth: 1)
            )
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
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.45))
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
                .shadow(color: Theme.primaryAccent.opacity(0.40), radius: size * 0.4, x: 0, y: size * 0.15)
            Text(name.prefix(1).uppercased())
                .font(.system(size: size * 0.40, weight: .heavy, design: .rounded))
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
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.45))
                .textCase(.uppercase)
            Spacer()
            if let trailing = trailing {
                trailing
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - View Extensions
extension View {
    @ViewBuilder
    func halfSheetIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents([.medium, .large])
        } else {
            self
        }
    }
}
