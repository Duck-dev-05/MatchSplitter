import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var name: String = ""
    @State private var paymentID: String = ""
    @State private var paymentType: String = "None"
    @State private var currentStep: Int = 1
    @State private var selectedCurrency: Currency = .usd
    @State private var isAnimating: Bool = false
    
    let paymentTypes = ["PromptPay", "Bank Transfer", "PayPal", "None"]
    
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
                    Text(currentStep == 1 ? "Welcome" : "Setup Payment")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if currentStep == 1 {
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
                        
                        Button(action: {
                            withAnimation { currentStep = 2 }
                        }) {
                            Text("Next")
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
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Payment Type")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.caption)
                            
                            Menu {
                                ForEach(paymentTypes, id: \.self) { type in
                                    Button(type) { paymentType = type }
                                }
                            } label: {
                                HStack {
                                    Text(paymentType)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            }
                            
                            if paymentType != "None" {
                                Text("Payment ID / Details")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.caption)
                                TextField(placeholderFor(type: paymentType), text: $paymentID)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                            
                            Text("Default Currency")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.caption)
                            
                            Menu {
                                ForEach(Currency.allCases, id: \.self) { c in
                                    Button("\(c.rawValue) (\(c.symbol))") { selectedCurrency = c }
                                }
                            } label: {
                                HStack {
                                    Text("\(selectedCurrency.rawValue) (\(selectedCurrency.symbol))")
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            }
                        }
                        
                        Button(action: {
                            let finalType = paymentType == "None" ? nil : paymentType
                            let finalID = paymentType == "None" ? "" : paymentID
                            viewModel.completeOnboarding(name: name, paymentID: finalID, paymentType: finalType, defaultCurrency: selectedCurrency)
                        }) {
                            Text("Finish & Get Started")
                                .font(.headline)
                                .foregroundColor(Theme.primaryAccent)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                        .padding(.top, 10)
                        .disabled(paymentType != "None" && paymentID.isEmpty)
                        .opacity((paymentType != "None" && paymentID.isEmpty) ? 0.6 : 1.0)
                        
                        Button(action: {
                            withAnimation { currentStep = 1 }
                        }) {
                            Text("Back")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 5)
                    }
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
    
    func placeholderFor(type: String) -> String {
        switch type {
        case "PromptPay": return "e.g. 0812345678"
        case "Bank Transfer": return "Account Number & Bank"
        case "PayPal": return "Email address"
        default: return "Payment Details"
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
