import SwiftUI

struct Theme {
    // MARK: - Color Palette
    // Deep space backgrounds
    static let backgroundStart   = Color(red: 0.04, green: 0.04, blue: 0.12)
    static let backgroundMid     = Color(red: 0.07, green: 0.06, blue: 0.20)
    static let backgroundEnd     = Color(red: 0.10, green: 0.06, blue: 0.26)

    // Card surfaces — frosted glass feel
    static let cardBackground    = Color(red: 0.12, green: 0.11, blue: 0.22)
    static let cardBorder        = Color.white.opacity(0.09)
    static let cardBorderStrong  = Color.white.opacity(0.16)

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
    // Amber
    static let amber             = Color(red: 1.0, green: 0.75, blue: 0.10)
    // Electric purple (slightly lighter than primary)
    static let electricPurple    = Color(red: 0.60, green: 0.35, blue: 1.00)

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
            colors: [primaryAccent, electricPurple, secondaryAccent.opacity(0.80)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var roseGradient: LinearGradient {
        LinearGradient(
            colors: [dangerColor, Color(red: 1.0, green: 0.45, blue: 0.35)],
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

    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [amber, warmGold],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cyanGradient: LinearGradient {
        LinearGradient(
            colors: [secondaryAccent, Color(red: 0.05, green: 0.65, blue: 0.90)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Legacy helpers (kept for compatibility)
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
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.14), Color.white.opacity(0.04)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.28), radius: 12, x: 0, y: 6)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Accent Card Modifier
struct AccentCardModifier: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.primaryAccent.opacity(0.28),
                                    Theme.secondaryAccent.opacity(0.12),
                                    Theme.primaryAccent.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Theme.primaryAccent.opacity(0.45), Theme.secondaryAccent.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Theme.primaryAccent.opacity(0.22), radius: 18, x: 0, y: 10)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Premium Card Modifier (stronger glow, gradient border)
struct PremiumCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var accentColor: Color

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Theme.cardBackground)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [accentColor.opacity(0.55), accentColor.opacity(0.15), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }
            )
            .shadow(color: accentColor.opacity(0.18), radius: 16, x: 0, y: 8)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Pressable Button Style
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.65), value: configuration.isPressed)
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

    func premiumCard(cornerRadius: CGFloat = 20, accentColor: Color = Theme.primaryAccent) -> some View {
        modifier(PremiumCardModifier(cornerRadius: cornerRadius, accentColor: accentColor))
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

// MARK: - Page Header
struct PageHeader: View {
    var title: String
    var subtitle: String? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.40))
                }
            }
            Spacer()
            if let trailing = trailing {
                trailing
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 6)
    }
}

// MARK: - Reusable Stat Badge
struct StatBadge: View {
    var icon: String
    var label: String
    var value: String
    var color: Color = Theme.primaryAccent

    var body: some View {
        VStack(spacing: 7) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Gradient Avatar
struct GradientAvatar: View {
    var name: String
    var avatarURL: String? = nil
    var size: CGFloat = 50
    var gradient: LinearGradient = Theme.primaryGradient

    var body: some View {
        if let urlString = avatarURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                        .shadow(color: Theme.primaryAccent.opacity(0.20), radius: 8, x: 0, y: 4)
                } else if phase.error != nil {
                    fallbackView
                } else {
                    ZStack {
                        Circle().fill(Theme.cardBackground).frame(width: size, height: size)
                        ProgressView().tint(Theme.secondaryAccent)
                    }
                }
            }
        } else {
            fallbackView
        }
    }

    private var fallbackView: some View {
        ZStack {
            Circle()
                .fill(gradient)
                .frame(width: size, height: size)
                .shadow(color: Theme.primaryAccent.opacity(0.22), radius: 8, x: 0, y: 4)
            Text(name.prefix(1).uppercased())
                .font(.system(size: size * 0.38, weight: .heavy, design: .rounded))
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
                .kerning(1.2)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.50))
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
            .fill(Color.white.opacity(0.25))
            .frame(width: 36, height: 5)
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
                .foregroundColor(.white.opacity(0.55))
                .font(.headline)
            Spacer()
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
            Spacer()
            Button(trailingLabel, action: onTrailing)
                .font(.headline.weight(.bold))
                .foregroundColor(trailingEnabled ? trailingColor : Color.white.opacity(0.25))
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
                .fill(color.opacity(0.14))
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
                        .stroke(color.opacity(0.25), lineWidth: 0.8)
                )
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
    @State private var shimmerOffset: CGFloat = -1.0

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(label)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)

                // Shimmer sweep
                if isEnabled {
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.20), .clear],
                        startPoint: .init(x: shimmerOffset, y: 0.5),
                        endPoint: .init(x: shimmerOffset + 0.4, y: 0.5)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .allowsHitTesting(false)
                }
            }
            .background(
                ZStack {
                    if isEnabled {
                        Theme.primaryGradient
                    } else {
                        Color.white.opacity(0.08)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: isEnabled
                                ? [Color.white.opacity(0.30), Color.white.opacity(0.06)]
                                : [Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: isEnabled ? Theme.primaryAccent.opacity(0.50) : .clear, radius: 16, x: 0, y: 8)
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .buttonStyle(PressableButtonStyle())
        .onAppear {
            guard isEnabled else { return }
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false).delay(0.6)) {
                shimmerOffset = 1.6
            }
        }
    }
}

// MARK: - Ambient Glow Blob
struct AmbientGlob: View {
    var color: Color = Theme.primaryAccent
    var size: CGFloat = 240
    var blurRadius: CGFloat = 80
    var opacity: Double = 0.09
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0

    var body: some View {
        Circle()
            .fill(color.opacity(opacity))
            .frame(width: size, height: size)
            .blur(radius: blurRadius)
            .offset(x: offsetX, y: offsetY)
            .allowsHitTesting(false)
    }
}

// MARK: - Neon Glow Modifier
struct NeonGlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.55), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.30), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    func neonGlow(_ color: Color = Theme.primaryAccent, radius: CGFloat = 12) -> some View {
        modifier(NeonGlowModifier(color: color, radius: radius))
    }
}

// MARK: - Shimmer Loading Modifier
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, Color.white.opacity(0.15), .clear],
                    startPoint: .init(x: phase, y: 0.5),
                    endPoint: .init(x: phase + 0.5, y: 0.5)
                )
                .allowsHitTesting(false)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    func shimmerLoading() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Hero Metric Card
struct HeroMetricCard: View {
    var icon: String
    var label: String
    var value: String
    var color: Color = Theme.primaryAccent
    var valueFont: CGFloat = 28

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color.opacity(0.14))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(color.opacity(0.28), lineWidth: 1)
                    )
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(value)
                .font(.system(size: valueFont, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.45))
                .textCase(.uppercase)
                .kerning(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.35), color.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: color.opacity(0.18), radius: 14, x: 0, y: 7)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var icon: String
    var title: String
    var subtitle: String
    var actionLabel: String? = nil
    var secondaryLabel: String? = nil
    var onAction: (() -> Void)? = nil
    var onSecondary: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            // Icon circle with glow
            ZStack {
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.10))
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle().stroke(Theme.primaryAccent.opacity(0.20), lineWidth: 1)
                    )
                Text(icon)
                    .font(.system(size: 38))
            }
            .neonGlow(Theme.primaryAccent, radius: 14)

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.50))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            if let label = actionLabel {
                Button(action: { onAction?() }) {
                    Text(label)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 13)
                        .background(Theme.primaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: Theme.primaryAccent.opacity(0.40), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(PressableButtonStyle())
            }

            if let label = secondaryLabel {
                Button(action: { onSecondary?() }) {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.60))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 11)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(32)
    }
}

// MARK: - Layout Metrics (Adaptive sizing for all screen sizes)
struct LayoutMetrics {
    let screenWidth: CGFloat

    // Tiers: small = SE/iPhone7/mini (<=375), large = Plus/Max (>=430), regular = everything else
    var isSmall: Bool { screenWidth <= 375 }
    var isLarge: Bool { screenWidth >= 430 }

    // MARK: Horizontal Padding
    var hPad: CGFloat            { isSmall ? 14 : (isLarge ? 28 : 20) }
    var hPadCard: CGFloat        { isSmall ? 12 : (isLarge ? 24 : 18) }

    // MARK: Vertical Spacing
    var sectionSpacing: CGFloat  { isSmall ? 12 : (isLarge ? 26 : 20) }
    var cardSpacing: CGFloat     { isSmall ? 8  : (isLarge ? 16 : 12) }
    var cardInnerPad: CGFloat    { isSmall ? 14 : (isLarge ? 28 : 20) }

    // MARK: Font Sizes
    var heroBalanceFont: CGFloat { isSmall ? 30 : (isLarge ? 52 : 46) }
    var heroTitleFont: CGFloat   { isSmall ? 20 : (isLarge ? 34 : 28) }
    var appTitleFont: CGFloat    { isSmall ? 26 : (isLarge ? 42 : 34) }
    var sectionFont: CGFloat     { isSmall ? 17 : (isLarge ? 24 : 22) }
    var bodyFont: CGFloat        { isSmall ? 13 : (isLarge ? 17 : 15) }
    var captionFont: CGFloat     { isSmall ? 10 : (isLarge ? 13 : 12) }
    var labelFont: CGFloat       { isSmall ? 12 : (isLarge ? 16 : 14) }

    // MARK: Avatar / Icon Sizes
    var avatarSize: CGFloat      { isSmall ? 34 : (isLarge ? 50 : 44) }
    var heroAvatarSize: CGFloat  { isSmall ? 68 : (isLarge ? 120 : 96) }
    var heroAvatarRing: CGFloat  { isSmall ? 80 : (isLarge ? 135 : 112) }
    var logoCircleSize: CGFloat  { isSmall ? 90  : (isLarge ? 145 : 120) }
    var logoIconFont: CGFloat    { isSmall ? 38 : (isLarge ? 70 : 54) }
    var logoLargeCircle: CGFloat { isSmall ? 100 : (isLarge ? 162 : 136) }

    // MARK: Card Corners
    var cardCorner: CGFloat      { isSmall ? 16 : (isLarge ? 28 : 22) }
    var sheetCorner: CGFloat     { isSmall ? 20 : (isLarge ? 32 : 28) }

    // MARK: Tab Bar
    var tabIconFont: CGFloat     { isSmall ? 18 : 22 }
    var tabBottomPad: CGFloat    { isSmall ? 14 : 24 }
    var fabSize: CGFloat         { isSmall ? 46 : (isLarge ? 60 : 54) }
    var fabFont: CGFloat         { isSmall ? 18 : 24 }

    // MARK: Quick Action Strip
    var actionBtnHeight: CGFloat { isSmall ? 36 : 44 }
    var actionIconSize: CGFloat  { isSmall ? 38 : 48 }

    // MARK: Generic Helper
    func adaptive<T>(_ small: T, _ regular: T, _ large: T) -> T {
        isSmall ? small : (isLarge ? large : regular)
    }
}

// MARK: - LayoutMetrics Environment Key
private struct LayoutMetricsKey: EnvironmentKey {
    static let defaultValue = LayoutMetrics(screenWidth: 390)
}

extension EnvironmentValues {
    var layoutMetrics: LayoutMetrics {
        get { self[LayoutMetricsKey.self] }
        set { self[LayoutMetricsKey.self] = newValue }
    }
}

extension View {
    func injectLayoutMetrics(width: CGFloat) -> some View {
        self.environment(\.layoutMetrics, LayoutMetrics(screenWidth: width))
    }

    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

