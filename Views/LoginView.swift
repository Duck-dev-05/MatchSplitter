import SwiftUI

enum AuthMode {
    case login
    case registerStep1
    case registerStep2
}

struct LoginView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    
    @State private var mode: AuthMode = .login
    @State private var email = ""
    @State private var password = ""
    
    @State private var name: String = ""
    @State private var paymentID: String = ""
    @State private var paymentType: String = "None"
    @State private var selectedCurrency: Currency? = nil
    
    @State private var isAnimating: Bool = false
    @State private var errorMessage: String = ""
    
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
                    Text(mode == .login ? "Login" : (mode == .registerStep1 ? "Register" : "Setup Payment"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Auth Segmented Control
                    if mode != .registerStep2 {
                        HStack {
                            Button("Login") { mode = .login; errorMessage = "" }
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(mode == .login ? Color.white.opacity(0.2) : Color.clear)
                                .cornerRadius(10)
                                .foregroundColor(mode == .login ? .white : .white.opacity(0.5))
                            
                            Button("Register") { mode = .registerStep1; errorMessage = "" }
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(mode == .registerStep1 ? Color.white.opacity(0.2) : Color.clear)
                                .cornerRadius(10)
                                .foregroundColor(mode == .registerStep1 ? .white : .white.opacity(0.5))
                        }
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.bottom, 10)
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(Theme.dangerColor)
                            .padding(.bottom, 5)
                    }
                    
                    if mode == .login {
                        VStack(alignment: .leading, spacing: 15) {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: handleLogin) {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(Theme.primaryAccent)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                        .padding(.top, 10)
                        .disabled(email.isEmpty || password.isEmpty)
                        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                        
                    } else if mode == .registerStep1 {
                        VStack(alignment: .leading, spacing: 15) {
                            TextField("Your Name", text: $name)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            if viewModel.registeredUsers.contains(where: { $0.email == email }) {
                                errorMessage = "Email already in use."
                            } else {
                                errorMessage = ""
                                withAnimation { mode = .registerStep2 }
                            }
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
                        .disabled(name.isEmpty || email.isEmpty || password.isEmpty)
                        .opacity(name.isEmpty || email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                        
                    } else if mode == .registerStep2 {
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
                                    if let currency = selectedCurrency {
                                        Text("\(currency.rawValue) (\(currency.symbol))")
                                    } else {
                                        Text("Select Currency")
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            }
                        }
                        
                        Button(action: handleRegister) {
                            Text("Finish & Register")
                                .font(.headline)
                                .foregroundColor(Theme.primaryAccent)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                        .padding(.top, 10)
                        .disabled((paymentType != "None" && paymentID.isEmpty) || selectedCurrency == nil)
                        .opacity(((paymentType != "None" && paymentID.isEmpty) || selectedCurrency == nil) ? 0.6 : 1.0)
                        
                        Button(action: {
                            withAnimation { mode = .registerStep1 }
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
    
    private func handleLogin() {
        if let user = viewModel.registeredUsers.first(where: { $0.email == email && $0.password == password }) {
            viewModel.login(user: user)
        } else {
            errorMessage = "Invalid email or password."
        }
    }
    
    private func handleRegister() {
        guard let currency = selectedCurrency else { return }
        let finalType = paymentType == "None" ? nil : paymentType
        let finalID = paymentType == "None" ? "" : paymentID
        
        let newUser = User(name: name, email: email, password: password, paymentID: finalID, paymentType: finalType)
        viewModel.register(user: newUser, defaultCurrency: currency)
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
