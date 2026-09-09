import SwiftUI

struct LandingView: View {
    @State private var showLogin = false
    @State private var isAnimating = false

    var body: some View {
        if showLogin {
            LoginView()
        } else {
            ZStack {
                // Animated Background
                LinearGradient(
                    gradient: Gradient(colors: [Theme.primaryAccent.opacity(0.8), Theme.secondaryAccent.opacity(0.8), Theme.backgroundEnd]),
                    startPoint: isAnimating ? .topLeading : .bottomTrailing,
                    endPoint: isAnimating ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .animation(Animation.easeInOut(duration: 5.0).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo and Title
                    VStack(spacing: 15) {
                        Image(systemName: "figure.sporting.court")
                            .font(.system(size: 90))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("MatchSplitter")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("Split expenses with your team seamlessly.")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation { showLogin = true }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(Theme.primaryAccent)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            }
        }
    }
}
