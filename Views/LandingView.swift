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
                // Deep animated gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Theme.backgroundStart,
                        Theme.primaryAccent.opacity(0.55),
                        Theme.secondaryAccent.opacity(0.35),
                        Theme.backgroundEnd
                    ]),
                    startPoint: isAnimating ? .topLeading : .bottomTrailing,
                    endPoint: isAnimating ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .animation(Animation.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: isAnimating)

                // Floating particle blobs
                GeometryReader { geo in
                    // Primary violet blob
                    Circle()
                        .fill(Theme.primaryAccent.opacity(0.18))
                        .frame(width: 280, height: 280)
                        .blur(radius: 70)
                        .offset(
                            x: isAnimating ? geo.size.width * 0.65 : geo.size.width * 0.45,
                            y: isAnimating ? geo.size.height * 0.08 : geo.size.height * 0.18
                        )
                        .animation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true), value: isAnimating)

                    // Cyan blob
                    Circle()
                        .fill(Theme.secondaryAccent.opacity(0.14))
                        .frame(width: 200, height: 200)
                        .blur(radius: 55)
                        .offset(
                            x: isAnimating ? geo.size.width * 0.04 : geo.size.width * 0.14,
                            y: isAnimating ? geo.size.height * 0.62 : geo.size.height * 0.72
                        )
                        .animation(.easeInOut(duration: 10.0).repeatForever(autoreverses: true), value: isAnimating)

                    // Rose accent blob
                    Circle()
                        .fill(Theme.dangerColor.opacity(0.09))
                        .frame(width: 140, height: 140)
                        .blur(radius: 40)
                        .offset(
                            x: isAnimating ? geo.size.width * 0.42 : geo.size.width * 0.58,
                            y: isAnimating ? geo.size.height * 0.40 : geo.size.height * 0.30
                        )
                        .animation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true), value: isAnimating)
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Logo and Title
                    VStack(spacing: metrics.adaptive(16, 22, 26)) {
                        // Icon with layered glow rings
                        ZStack {
                            // Outer rotating gradient ring
                            Circle()
                                .strokeBorder(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Theme.primaryAccent.opacity(0.7),
                                            Theme.secondaryAccent.opacity(0.5),
                                            Theme.primaryAccent.opacity(0.2),
                                            Theme.secondaryAccent.opacity(0.7),
                                            Theme.primaryAccent.opacity(0.7)
                                        ]),
                                        center: .center
                                    ),
                                    lineWidth: 1.5
                                )
                                .frame(width: metrics.logoLargeCircle + 20, height: metrics.logoLargeCircle + 20)
                                .rotationEffect(.degrees(ringRotation))

                            // Inner glow ring
                            Circle()
                                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                                .frame(width: metrics.logoLargeCircle, height: metrics.logoLargeCircle)

                            // Core icon circle
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.white.opacity(0.20), Color.white.opacity(0.08)],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: metrics.logoCircleSize / 2
                                    )
                                )
                                .frame(width: metrics.logoCircleSize, height: metrics.logoCircleSize)
                                .shadow(color: Theme.primaryAccent.opacity(0.45), radius: 30, x: 0, y: 10)

                            Image(systemName: "figure.sporting.court")
                                .font(.system(size: metrics.logoIconFont))
                                .foregroundColor(.white)
                                .shadow(color: Theme.primaryAccent.opacity(0.30), radius: 10, x: 0, y: 4)
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
                        .background(
                            ZStack {
                                LinearGradient(
                                    colors: [Theme.primaryAccent, Theme.secondaryAccent.opacity(0.90)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Theme.primaryAccent.opacity(0.60), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.30), Color.white.opacity(0.06)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.horizontal, metrics.hPad)
                    .padding(.bottom, metrics.adaptive(44, 64, 74))
                }
            }
            .onAppear {
                isAnimating = true
                withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                    ringRotation = 360
                }
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
