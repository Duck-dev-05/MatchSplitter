import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    @State private var isAnimating = false
    @Environment(\.layoutMetrics) var metrics
    
    let pages: [OnboardingPage] = [
        OnboardingPage(title: "Welcome to\nMatchSplitter", description: "The easiest and most elegant way to split bills with your friends, roommates, and travel buddies.", imageName: "figure.sporting.court", color: Theme.primaryAccent),
        OnboardingPage(title: "Snap & Extract", description: "Simply snap a photo of your receipt and let AI extract the line items for you automatically.", imageName: "camera.macro", color: Theme.secondaryAccent),
        OnboardingPage(title: "Settle Up", description: "Keep track of who owes who and settle up using generated QR codes for seamless payments.", imageName: "qrcode.viewfinder", color: Theme.successColor)
    ]
    
    var body: some View {
        ZStack {
            // Immersive animated background
            Theme.backgroundGradient.ignoresSafeArea()
            
            // Dynamic ambient glow based on current page
            AmbientGlob(
                color: pages[currentPage].color,
                size: 300,
                blurRadius: 100,
                opacity: 0.15,
                offsetX: currentPage == 0 ? -100 : (currentPage == 1 ? 0 : 100),
                offsetY: currentPage == 0 ? -100 : (currentPage == 1 ? 0 : 100)
            )
            .animation(.easeInOut(duration: 1.0), value: currentPage)
            
            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    Button(action: { endOnboarding() }) {
                        Text("Skip")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    }
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], isAnimating: isAnimating && currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom Control Bar (Glassmorphic)
                bottomControlBar
                    .padding(.horizontal, metrics.hPad)
                    .padding(.bottom, metrics.adaptive(30, 40, 50))
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private var bottomControlBar: some View {
        HStack {
            // Custom Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index ? pages[index].color : Color.white.opacity(0.2))
                        .frame(width: currentPage == index ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                }
            }
            .padding(.leading, 8)
            
            Spacer()
            
            // Next / Get Started Button
            Button(action: {
                if currentPage < pages.count - 1 {
                    withAnimation(.spring()) {
                        currentPage += 1
                    }
                } else {
                    endOnboarding()
                }
            }) {
                HStack(spacing: 8) {
                    Text(currentPage == pages.count - 1 ? "Start" : "Next")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule().fill(pages[currentPage].color.opacity(0.8))
                )
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: pages[currentPage].color.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(16)
        .glassCard(cornerRadius: 30)
    }
    
    private func endOnboarding() {
        withAnimation(.easeOut(duration: 0.3)) {
            hasSeenOnboarding = true
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    var isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Hero Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Circle()
                    .stroke(page.color.opacity(0.3), lineWidth: 2)
                    .frame(width: 220, height: 220)
                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                    .opacity(isAnimating ? 0.5 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.2), value: isAnimating)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 80, weight: .ultraLight))
                    .foregroundColor(page.color)
                    .shadow(color: page.color.opacity(0.5), radius: 20, x: 0, y: 10)
                    .offset(y: isAnimating ? -10 : 10)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
            }
            
            // Text Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            .padding(.bottom, 20)
            
            Spacer()
            Spacer() // Push content up slightly to make room for bottom bar
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
