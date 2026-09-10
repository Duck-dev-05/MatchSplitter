import SwiftUI

struct LandingView: View {
    @State private var showLogin = false
    @State private var isAnimating = false

    var body: some View {
        if showLogin {
            LoginView()
        } else {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Theme.primaryAccent.opacity(0.85), Theme.secondaryAccent.opacity(0.75), Theme.backgroundEnd]),
                    startPoint: isAnimating ? .topLeading : .bottomTrailing,
                    endPoint: isAnimating ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .animation(Animation.easeInOut(duration: 5.0).repeatForever(autoreverses: true), value: isAnimating)

                // Floating particle blobs
                GeometryReader { geo in
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 220, height: 220)
                        .blur(radius: 50)
                        .offset(
                            x: isAnimating ? geo.size.width * 0.7 : geo.size.width * 0.5,
                            y: isAnimating ? geo.size.height * 0.1 : geo.size.height * 0.2
                        )
                        .animation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true), value: isAnimating)

                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 160, height: 160)
                        .blur(radius: 45)
                        .offset(
                            x: isAnimating ? geo.size.width * 0.05 : geo.size.width * 0.15,
                            y: isAnimating ? geo.size.height * 0.60 : geo.size.height * 0.70
                        )
                        .animation(.easeInOut(duration: 10.0).repeatForever(autoreverses: true), value: isAnimating)

                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 100, height: 100)
                        .blur(radius: 30)
                        .offset(
                            x: isAnimating ? geo.size.width * 0.4 : geo.size.width * 0.6,
                            y: isAnimating ? geo.size.height * 0.45 : geo.size.height * 0.35
                        )
                        .animation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: isAnimating)
                }
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    // Logo and Title
                    VStack(spacing: 18) {
                        // Icon with glow ring
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.10))
                                .frame(width: 130, height: 130)
                                .shadow(color: Color.white.opacity(0.35), radius: 30, x: 0, y: 10)

                            Circle()
                                .stroke(Color.white.opacity(0.22), lineWidth: 1.5)
                                .frame(width: 145, height: 145)

                            Image(systemName: "figure.sporting.court")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }

                        Text("MatchSplitter")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)

                        Text("Split expenses with your team\nseamlessly.")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    Spacer()

                    // Feature chips row
                    HStack(spacing: 10) {
                        featureChip(icon: "arrow.left.arrow.right", text: "Smart Split")
                        featureChip(icon: "qrcode", text: "QR Pay")
                        featureChip(icon: "chart.bar.fill", text: "Analytics")
                    }
                    .padding(.horizontal, 30)

                    Spacer().frame(height: 10)

                    // Get Started – gradient button
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showLogin = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Theme.primaryAccent, Theme.secondaryAccent.opacity(0.80)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Theme.primaryAccent.opacity(0.55), radius: 16, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.22), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.horizontal, 30)
                    .padding(.bottom, 60)
                }
            }
            .onAppear { isAnimating = true }
        }
    }

    private func featureChip(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(.white.opacity(0.85))
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.14))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.20), lineWidth: 1))
    }
}
