import SwiftUI

struct LandingView: View {
    @State private var showLogin = false
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var floatOffset: CGFloat = 0.0
    @Environment(\.layoutMetrics) var metrics

    var body: some View {
        if showLogin {
            LoginView()
        } else {
            ZStack {
                // Immersive gradient background
                Theme.backgroundGradient
                    .ignoresSafeArea()

                // Animated ambient light
                AmbientGlob(color: Theme.primaryAccent, size: 400, blurRadius: 120, opacity: 0.15, offsetX: -100, offsetY: floatOffset)
                AmbientGlob(color: Theme.secondaryAccent, size: 300, blurRadius: 100, opacity: 0.12, offsetX: 150, offsetY: -floatOffset)

                VStack(spacing: 0) {
                    Spacer()

                    // Logo and Title
                    VStack(spacing: metrics.adaptive(20, 28, 34)) {
                        // Floating Hero Icon
                        ZStack {
                            Circle()
                                .fill(Theme.primaryAccent.opacity(0.12))
                                .frame(width: metrics.logoCircleSize * 1.2, height: metrics.logoCircleSize * 1.2)
                                .scaleEffect(pulseScale)
                                .shadow(color: Theme.primaryAccent.opacity(0.2), radius: 20, x: 0, y: 10)
                            
                            Circle()
                                .stroke(Theme.primaryAccent.opacity(0.3), lineWidth: 1)
                                .frame(width: metrics.logoCircleSize * 1.4, height: metrics.logoCircleSize * 1.4)
                                .scaleEffect(pulseScale * 1.05)

                            Image(systemName: "figure.sporting.court")
                                .font(.system(size: metrics.logoIconFont * 1.2, weight: .thin))
                                .foregroundColor(Theme.primaryAccent)
                        }
                        .offset(y: floatOffset * 0.5)

                        // App name
                        VStack(spacing: 12) {
                            Text("MatchSplitter")
                                .font(.system(size: metrics.appTitleFont + 4, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)

                            Text("Split expenses with your team\nseamlessly and beautifully.")
                                .font(.system(size: metrics.bodyFont + 2, weight: .medium))
                                .foregroundColor(.white.opacity(0.70))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, metrics.hPad + 10)
                        }
                    }

                    Spacer()

                    // Feature chips row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            featureChip(icon: "bolt.fill", text: "Instant", color: Theme.warmGold)
                            featureChip(icon: "qrcode.viewfinder", text: "QR Pay", color: Theme.secondaryAccent)
                            featureChip(icon: "chart.pie.fill", text: "Analytics", color: Theme.primaryAccent)
                            featureChip(icon: "globe", text: "Currencies", color: Theme.successColor)
                        }
                        .padding(.horizontal, metrics.hPad)
                    }
                    .padding(.bottom, metrics.adaptive(30, 40, 50))

                    // Get Started button
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showLogin = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text("Login / Register")
                                .font(.system(size: metrics.bodyFont + 3, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: metrics.bodyFont + 1, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, metrics.adaptive(16, 20, 24))
                        .background(Theme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Theme.primaryAccent.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.94))
                    .padding(.horizontal, metrics.hPad)
                    .padding(.bottom, metrics.adaptive(44, 64, 74))
                }
            }
            .onAppear {
                isAnimating = true
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    pulseScale = 1.08
                }
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    floatOffset = -20
                }
            }
        }
    }

    private func featureChip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
        .shadow(color: color.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}
