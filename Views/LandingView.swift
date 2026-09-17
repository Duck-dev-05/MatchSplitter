import SwiftUI

struct LandingView: View {
    @State private var showLogin = false
    @State private var isAnimating = false
    @State private var ringRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @Environment(\.layoutMetrics) var metrics

    var body: some View {
        if showLogin {
            LoginView()
        } else {
            ZStack {
                // Clean pastel gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Theme.backgroundStart,
                        Theme.backgroundEnd
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Logo and Title
                    VStack(spacing: metrics.adaptive(16, 22, 26)) {
                        // Clean Soft Icon
                        ZStack {
                            Circle()
                                .fill(Theme.primaryAccent.opacity(0.15))
                                .frame(width: metrics.logoCircleSize, height: metrics.logoCircleSize)
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)

                            Image(systemName: "figure.sporting.court")
                                .font(.system(size: metrics.logoIconFont))
                                .foregroundColor(Theme.primaryAccent)
                        }
                        .scaleEffect(pulseScale)

                        // App name
                        Text("MatchSplitter")
                            .font(.system(size: metrics.appTitleFont, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Theme.primaryAccent.opacity(0.25), radius: 12, x: 0, y: 4)

                        Text("Split expenses with your team\nseamlessly.")
                            .font(.system(size: metrics.bodyFont + 1, weight: .medium))
                            .foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, metrics.hPad + 10)
                    }

                    Spacer()

                    // Feature chips row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            featureChip(icon: "arrow.left.arrow.right", text: "Smart Split", color: Theme.primaryAccent)
                            featureChip(icon: "qrcode.viewfinder", text: "QR Pay", color: Theme.secondaryAccent)
                            featureChip(icon: "chart.bar.fill", text: "Analytics", color: Theme.successColor)
                            featureChip(icon: "globe", text: "Multi-Currency", color: Theme.warmGold)
                        }
                        .padding(.horizontal, metrics.hPad)
                    }
                    .padding(.bottom, metrics.adaptive(16, 24, 28))

                    // Get Started button
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showLogin = true
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text("Get Started")
                                .font(.system(size: metrics.bodyFont + 2, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: metrics.bodyFont, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, metrics.adaptive(14, 18, 20))
                        .background(Theme.primaryAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.horizontal, metrics.hPad)
                    .padding(.bottom, metrics.adaptive(44, 64, 74))
                }
            }
            .onAppear {
                isAnimating = true
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    pulseScale = 1.05
                }
            }
        }
    }

    private func featureChip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.90))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(Capsule().stroke(color.opacity(0.25), lineWidth: 1))
        )
    }
}
