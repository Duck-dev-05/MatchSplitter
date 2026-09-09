import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var name: String = ""
    @State private var paymentID: String = ""
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            // Animated Background
            LinearGradient(gradient: Gradient(colors: [Theme.primaryAccent, Theme.secondaryAccent, Theme.backgroundEnd]),
                           startPoint: isAnimating ? .topLeading : .bottomTrailing,
                           endPoint: isAnimating ? .bottomTrailing : .topLeading)
                .ignoresSafeArea()
                .animation(Animation.easeInOut(duration: 5.0).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo/Header
                VStack(spacing: 15) {
                    Image(systemName: "figure.sporting.court")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("MatchSplitter")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                }
                
                // Glassmorphic Card
                VStack(spacing: 20) {
                    Text("Welcome")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading) {
                        Text("Your Name")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                        TextField("Enter your name", text: $name)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Payment ID (PromptPay / Bank)")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                        TextField("e.g. 0812345678", text: $paymentID)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        if !name.isEmpty {
                            viewModel.completeOnboarding(name: name, paymentID: paymentID)
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(Theme.primaryAccent)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 10)
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.6 : 1.0)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.15))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                )
                .background(BlurView(style: .systemUltraThinMaterialDark).cornerRadius(25))
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(GroupViewModel())
    }
}
