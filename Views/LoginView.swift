import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

enum AuthMode {
    case login
    case registerStep1
    case registerStep2
}

struct LoginView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var mode: AuthMode = .login
    @State private var email = ""
    @State private var password = ""

    @State private var name: String = ""
    @State private var paymentID: String = ""
    @State private var paymentType: String = "None"
    @State private var selectedCurrency: Currency? = .vnd

    @State private var bankBin: String = ""
    @State private var banks: [VietQRBank] = []
    @State private var isLoadingBanks = false

    @State private var payOSClientId: String = ""
    @State private var payOSApiKey: String = ""
    @State private var payOSChecksumKey: String = ""

    @State private var isAnimating: Bool = false
    @State private var errorMessage: String = ""
    @State private var segmentOffset: CGFloat = 0

    let paymentTypes = ["PromptPay", "Bank Transfer", "PayPal", "VietQR", "PayOS", "None"]

    var isModal: Bool = true

    // Whether form is valid for the current step
    var isStepValid: Bool {
        switch mode {
        case .login:         return !email.isEmpty && !password.isEmpty
        case .registerStep1: return !name.isEmpty && !email.isEmpty && !password.isEmpty
        case .registerStep2: 
            if paymentType == "VietQR" {
                return selectedCurrency != nil && !paymentID.isEmpty && !bankBin.isEmpty
            } else if paymentType == "PayOS" {
                return selectedCurrency != nil && !payOSClientId.isEmpty && !payOSApiKey.isEmpty && !payOSChecksumKey.isEmpty
            }
            return selectedCurrency != nil && !(paymentType != "None" && paymentID.isEmpty)
        }
    }

    var body: some View {
        ZStack {
            // Animated Background
            LinearGradient(
                gradient: Gradient(colors: [Theme.primaryAccent, Theme.secondaryAccent, Theme.backgroundEnd]),
                startPoint: isAnimating ? .topLeading : .bottomTrailing,
                endPoint: isAnimating ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(Animation.easeInOut(duration: 5.0).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear { isAnimating = true }

            // Particle blobs
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: isAnimating ? geo.size.width * 0.75 : geo.size.width * 0.5,
                            y: isAnimating ? geo.size.height * 0.15 : geo.size.height * 0.25)
                    .animation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true), value: isAnimating)

                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 150, height: 150)
                    .blur(radius: 40)
                    .offset(x: isAnimating ? geo.size.width * 0.05 : geo.size.width * 0.2,
                            y: isAnimating ? geo.size.height * 0.65 : geo.size.height * 0.55)
                    .animation(.easeInOut(duration: 9.0).repeatForever(autoreverses: true), value: isAnimating)
            }
            .ignoresSafeArea()

            VStack(spacing: 30) {
                if isModal {
                    HStack {
                        Spacer()
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 40)
                } else {
                    Spacer().frame(height: 64)
                }

                Spacer()

                // Logo / Header
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.white.opacity(0.3), radius: 25, x: 0, y: 10)
                        Image(systemName: "figure.sporting.court")
                            .font(.system(size: 54))
                            .foregroundColor(.white)
                    }

                    Text("MatchSplitter")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }

                // Glass Card
                VStack(spacing: 20) {
                    Text(mode == .login ? "Welcome Back" : (mode == .registerStep1 ? "Create Account" : "Payment Setup"))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    // Segmented Control with animated sliding indicator
                    if mode != .registerStep2 {
                        animatedSegmentControl
                    }

                    // Error Message
                    if !errorMessage.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 13))
                            Text(errorMessage)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(Theme.dangerColor)
                        .padding(.bottom, 2)
                    }

                    // Form fields
                    if mode == .login {
                        loginFields
                    } else if mode == .registerStep1 {
                        registerStep1Fields
                    } else {
                        registerStep2Fields
                    }
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white.opacity(0.12))
                        .background(
                            BlurView(style: .systemUltraThinMaterialDark)
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                        )
                        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    // MARK: - Animated Segment Control
    private var animatedSegmentControl: some View {
        ZStack(alignment: .leading) {
            // Track
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .frame(height: 40)

            // Sliding pill
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.20))
                    .frame(width: geo.size.width / 2, height: 34)
                    .offset(x: mode == .login ? 3 : geo.size.width / 2 - 3, y: 3)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: mode)
            }

            HStack(spacing: 0) {
                Button("Login") { mode = .login; errorMessage = "" }
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 15, weight: mode == .login ? .bold : .regular))
                    .foregroundColor(mode == .login ? .white : .white.opacity(0.5))

                Button("Register") { mode = .registerStep1; errorMessage = "" }
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 15, weight: mode == .registerStep1 ? .bold : .regular))
                    .foregroundColor(mode == .registerStep1 ? .white : .white.opacity(0.5))
            }
        }
        .frame(height: 40)
        .padding(.bottom, 4)
    }

    // MARK: - Login Fields
    private var loginFields: some View {
        VStack(spacing: 14) {
            glassTextField(icon: "envelope.fill", iconColor: Theme.secondaryAccent, placeholder: "Email", text: $email, keyboard: .emailAddress)
            glassTextField(icon: "lock.fill", iconColor: Theme.primaryAccent, placeholder: "Password", text: $password, isSecure: true)

            GradientButton(label: "Login", isEnabled: isStepValid, action: handleLogin)
                .padding(.top, 6)
            
            googleSignInSection
        }
    }

    // MARK: - Register Step 1 Fields
    private var registerStep1Fields: some View {
        VStack(spacing: 14) {
            glassTextField(icon: "person.fill", iconColor: Theme.primaryAccent, placeholder: "Your Name", text: $name)
            glassTextField(icon: "envelope.fill", iconColor: Theme.secondaryAccent, placeholder: "Email", text: $email, keyboard: .emailAddress)
            glassTextField(icon: "lock.fill", iconColor: Theme.warmGold, placeholder: "Password", text: $password, isSecure: true)

            GradientButton(label: "Next →", isEnabled: isStepValid) {
                if viewModel.registeredUsers.contains(where: { $0.email == email }) {
                    errorMessage = "Email already in use."
                } else {
                    errorMessage = ""
                    withAnimation { mode = .registerStep2 }
                }
            }
            .padding(.top, 6)
            
            googleSignInSection
        }
    }

    // MARK: - Register Step 2 Fields
    private var registerStep2Fields: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Payment type picker styled as glass field
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "building.columns.fill", color: Theme.secondaryAccent, size: 36, iconSize: 14)
                    Menu {
                        ForEach(paymentTypes, id: \.self) { type in
                            Button(type) { 
                                paymentType = type 
                                if type == "VietQR" && banks.isEmpty {
                                    Task { await loadBanks() }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(paymentType)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 12))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if paymentType != "None" {
                if paymentType == "VietQR" {
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            IconBadge(systemName: "building.2.fill", color: Theme.secondaryAccent, size: 36, iconSize: 14)
                            if isLoadingBanks {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Spacer()
                            } else {
                                Menu {
                                    ForEach(banks) { bank in
                                        Button("\(bank.shortName) - \(bank.name)") {
                                            bankBin = bank.bin
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(banks.first(where: { $0.bin == bankBin })?.shortName ?? "Select Bank")
                                            .foregroundColor(bankBin.isEmpty ? .white.opacity(0.5) : .white)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .foregroundColor(.white.opacity(0.6))
                                            .font(.system(size: 12))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    glassTextField(
                        icon: "number",
                        iconColor: Theme.secondaryAccent,
                        placeholder: "Account Number",
                        text: $paymentID,
                        keyboard: .numberPad
                    )
                } else if paymentType == "PayOS" {
                    glassTextField(icon: "person.badge.key.fill", iconColor: Theme.secondaryAccent, placeholder: "Client ID", text: $payOSClientId)
                    glassTextField(icon: "key.fill", iconColor: Theme.secondaryAccent, placeholder: "API Key", text: $payOSApiKey)
                    glassTextField(icon: "lock.fill", iconColor: Theme.secondaryAccent, placeholder: "Checksum Key", text: $payOSChecksumKey)
                } else {
                    glassTextField(
                        icon: "creditcard.fill",
                        iconColor: Theme.secondaryAccent,
                        placeholder: placeholderFor(type: paymentType),
                        text: $paymentID
                    )
                }
            }

            // Currency picker
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "banknote.fill", color: Theme.warmGold, size: 36, iconSize: 14)
                    Menu {
                        ForEach(Currency.allCases, id: \.self) { c in
                            Button("\(c.rawValue) (\(c.symbol))") { selectedCurrency = c }
                        }
                    } label: {
                        HStack {
                            if let currency = selectedCurrency {
                                Text("\(currency.rawValue) (\(currency.symbol))")
                                    .foregroundColor(.white)
                            } else {
                                Text("Select Currency")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 12))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            GradientButton(label: "Finish & Register", isEnabled: isStepValid, action: handleRegister)
                .padding(.top, 6)

            Button(action: { withAnimation { mode = .registerStep1 } }) {
                Text("← Back")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Glass Text Field
    private func glassTextField(
        icon: String,
        iconColor: Color,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        isSecure: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: iconColor, size: 36, iconSize: 14)
            if isSecure {
                SecureField(placeholder, text: text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    // MARK: - Handlers
    private func handleLogin() {
        if let user = viewModel.registeredUsers.first(where: { $0.email == email && $0.password == password }) {
            viewModel.login(user: user)
            presentationMode.wrappedValue.dismiss()
        } else {
            errorMessage = "Invalid email or password."
        }
    }
    
    private var googleSignInSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack { Divider().background(Color.white.opacity(0.3)) }
                Text("OR")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 8)
                VStack { Divider().background(Color.white.opacity(0.3)) }
            }
            .padding(.top, 8)

            GoogleSignInButton(action: handleGoogleSignIn)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        return screen.windows.first?.rootViewController
    }

    private func handleGoogleSignIn() {
        guard let rootViewController = getRootViewController() else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard error == nil else {
                self.errorMessage = error?.localizedDescription ?? "Google Sign-In failed."
                return
            }
            
            guard let user = signInResult?.user,
                  let profile = user.profile else { return }
            
            let name = profile.name
            let email = profile.email
            let avatarURL = profile.imageURL(withDimension: 320)?.absoluteString
            
            viewModel.loginOrRegisterWithGoogle(name: name, email: email, avatarURL: avatarURL)
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func handleRegister() {
        guard let currency = selectedCurrency else { return }
        let finalType = paymentType == "None" ? nil : paymentType
        let finalID = paymentType == "None" ? "" : paymentID
        let finalBin = paymentType == "VietQR" ? bankBin : nil
        let finalClientId = paymentType == "PayOS" ? payOSClientId : nil
        let finalApiKey = paymentType == "PayOS" ? payOSApiKey : nil
        let finalChecksumKey = paymentType == "PayOS" ? payOSChecksumKey : nil

        let newUser = User(
            name: name, 
            email: email, 
            password: password, 
            paymentID: finalID, 
            paymentType: finalType, 
            bankBin: finalBin,
            payOSClientId: finalClientId,
            payOSApiKey: finalApiKey,
            payOSChecksumKey: finalChecksumKey
        )
        viewModel.register(user: newUser, defaultCurrency: currency)
        presentationMode.wrappedValue.dismiss()
    }

    func placeholderFor(type: String) -> String {
        switch type {
        case "PromptPay": return "e.g. 0812345678"
        case "Bank Transfer": return "Account Number & Bank"
        case "PayPal": return "Email address"
        default: return "Payment Details"
        }
    }
    
    private func loadBanks() async {
        isLoadingBanks = true
        do {
            let fetchedBanks = try await VietQRService.shared.fetchBanks()
            await MainActor.run {
                self.banks = fetchedBanks
                self.isLoadingBanks = false
            }
        } catch {
            print("Failed to load banks: \(error)")
            await MainActor.run { self.isLoadingBanks = false }
        }
    }
}

// MARK: - Blur View
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
