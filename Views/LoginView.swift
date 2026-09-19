import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

enum AuthMode {
    case login
    case register
}

struct LoginView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.layoutMetrics) var metrics

    @State private var mode: AuthMode = .login
    @State private var email = ""
    @State private var password = ""
    @State private var name: String = ""
    @State private var selectedCurrency: Currency = .vnd

    @State private var isAnimating: Bool = false
    @State private var errorMessage: String = ""
    @State private var isAuthenticating: Bool = false
    @State private var showingForgotPassword: Bool = false
    @FocusState private var focusedField: LoginField?

    enum LoginField: Hashable {
        case email, password, name
    }

    var isModal: Bool = true

    var isStepValid: Bool {
        switch mode {
        case .login:    return !email.isEmpty && !password.isEmpty
        case .register: return !name.isEmpty && !email.isEmpty && !password.isEmpty
        }
    }

    var body: some View {
        ZStack {
            // Animated Background
            LinearGradient(
                gradient: Gradient(colors: [Theme.primaryAccent, Theme.backgroundMid, Theme.backgroundEnd]),
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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top bar
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
                        .padding(.top, 50)
                        .padding(.bottom, metrics.isSmall ? 12 : 20)
                    } else {
                        Spacer().frame(height: metrics.isSmall ? 50 : 64)
                    }

                    // Logo / Header
                    VStack(spacing: metrics.adaptive(8, 12, 16)) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.18))
                                .frame(width: metrics.heroAvatarSize, height: metrics.heroAvatarSize)
                                .shadow(color: Color.white.opacity(0.25), radius: 20, x: 0, y: 8)
                            Image(systemName: "figure.sporting.court")
                                .font(.system(size: metrics.logoIconFont, weight: .semibold))
                                .foregroundColor(Theme.primaryAccent)
                        }
                        .neonGlow(Theme.primaryAccent, radius: 14)

                        Text("MatchSplitter")
                            .font(.system(size: metrics.appTitleFont, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                    }
                    .padding(.bottom, metrics.adaptive(12, 20, 24))

                    // Form Container
                    VStack(spacing: metrics.adaptive(12, 18, 22)) {
                        Text(mode == .login ? "Welcome Back" : "Create Account")
                            .font(.system(size: metrics.sectionFont, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        // Segmented Control
                        animatedSegmentControl

                        // Error Banner
                        if !errorMessage.isEmpty {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.dangerColor)
                                Text(errorMessage)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Theme.dangerColor)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Theme.dangerColor.opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Theme.dangerColor.opacity(0.28), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Form fields
                        if mode == .login {
                            loginFields
                        } else {
                            registerFields
                        }
                    }
                    .padding(.horizontal, metrics.hPad)
                    .overlay(
                        ZStack {
                            if isAuthenticating {
                                // Branded auth overlay
                                Color.black.opacity(0.65).cornerRadius(20)
                                VStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.14))
                                            .frame(width: 56, height: 56)
                                        Image(systemName: "figure.sporting.court")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(Theme.primaryAccent)
                                    }
                                    .neonGlow(Theme.primaryAccent, radius: 12)
                                    .shimmerLoading()

                                    Text("Authenticating...")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.80))
                                }
                                .padding(24)
                            }
                        }
                    )

                    Spacer().frame(height: isModal ? metrics.adaptive(30, 40, 50) : metrics.adaptive(100, 110, 120))
                }
            }
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
    }

    // MARK: - Animated Segment Control
    private var animatedSegmentControl: some View {
        ZStack(alignment: .leading) {
            // Track
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.07))
                .frame(height: 42)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )

            // Sliding gradient pill
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [Theme.primaryAccent.opacity(0.80), Theme.secondaryAccent.opacity(0.60)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width / 2, height: 34)
                    .offset(x: mode == .login ? 4 : geo.size.width / 2 - 4, y: 4)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: mode)
                    .shadow(color: Theme.primaryAccent.opacity(0.40), radius: 8, x: 0, y: 4)
            }

            HStack(spacing: 0) {
                Button("Login") { mode = .login; errorMessage = "" }
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 15, weight: mode == .login ? .bold : .semibold))
                    .foregroundColor(mode == .login ? .white : .white.opacity(0.45))

                Button("Register") { mode = .register; errorMessage = "" }
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 15, weight: mode == .register ? .bold : .semibold))
                    .foregroundColor(mode == .register ? .white : .white.opacity(0.45))
            }
        }
        .frame(height: 42)
        .padding(.bottom, 4)
    }

    // MARK: - Login Fields
    private var loginFields: some View {
        VStack(spacing: 14) {
            glassTextField(icon: "envelope.fill", iconColor: Theme.secondaryAccent, placeholder: "Email", text: $email, keyboard: .emailAddress, field: .email)
            glassTextField(icon: "lock.fill", iconColor: Theme.primaryAccent, placeholder: "Password", text: $password, isSecure: true, field: .password)

            HStack {
                Spacer()
                Button(action: { showingForgotPassword = true }) {
                    Text("Forgot Password?")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.secondaryAccent)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, -6)

            GradientButton(label: "Login", isEnabled: isStepValid, action: handleLogin)
                .padding(.top, 6)

            googleSignInSection
        }
    }

    // MARK: - Register Fields
    private var registerFields: some View {
        VStack(spacing: 14) {
            glassTextField(icon: "person.fill", iconColor: Theme.primaryAccent, placeholder: "Your Name", text: $name, field: .name)
            glassTextField(icon: "envelope.fill", iconColor: Theme.secondaryAccent, placeholder: "Email", text: $email, keyboard: .emailAddress, field: .email)
            glassTextField(icon: "lock.fill", iconColor: Theme.warmGold, placeholder: "Password", text: $password, isSecure: true, field: .password)
            
            // Simplified Currency Picker
            HStack(spacing: 12) {
                IconBadge(systemName: "banknote.fill", color: Theme.successColor, size: 36, iconSize: 14)
                Menu {
                    ForEach(Currency.allCases, id: \.self) { c in
                        Button("\(c.rawValue) (\(c.symbol))") { selectedCurrency = c }
                    }
                } label: {
                    HStack {
                        Text("\(selectedCurrency.rawValue) (\(selectedCurrency.symbol))")
                            .font(.system(size: 15))
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
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )

            GradientButton(label: "Register", isEnabled: isStepValid) {
                handleRegister()
            }
            .padding(.top, 6)

            googleSignInSection
        }
    }

    // MARK: - Glass Text Field
    private func glassTextField(
        icon: String,
        iconColor: Color,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        isSecure: Bool = false,
        field: LoginField? = nil
    ) -> some View {
        let isFocused = field != nil && focusedField == field
        return HStack(spacing: 12) {
            IconBadge(systemName: icon, color: isFocused ? iconColor : iconColor.opacity(0.7), size: 36, iconSize: 14)
            if isSecure {
                SecureField(placeholder, text: text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .focused($focusedField, equals: field ?? .email)
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .focused($focusedField, equals: field ?? .email)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(isFocused ? 0.14 : 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    isFocused ? iconColor.opacity(0.55) : Color.white.opacity(0.10),
                    lineWidth: isFocused ? 1.5 : 1
                )
        )
        .shadow(color: isFocused ? iconColor.opacity(0.20) : .clear, radius: 8, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }

    // MARK: - Handlers
    private func handleLogin() {
        isAuthenticating = true
        errorMessage = ""
        Task {
            if await self.authViewModel.authenticateUser(email: self.email, password: self.password) != nil {
                await MainActor.run {
                    if let user = self.authViewModel.currentUser {
                        self.viewModel.login(user: user)
                    }
                    self.isAuthenticating = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            } else {
                await MainActor.run {
                    self.isAuthenticating = false
                    self.errorMessage = "Invalid email or password."
                }
            }
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
            
            self.isAuthenticating = true
            self.errorMessage = ""
            Task {
                _ = await authViewModel.authenticateGoogleUser(name: name, email: email, avatarURL: avatarURL)
                await MainActor.run {
                    if let user = self.authViewModel.currentUser {
                        self.viewModel.login(user: user)
                    }
                    self.isAuthenticating = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func handleRegister() {
        let newUser = User(
            name: name, 
            email: email, 
            password: password, 
            paymentID: "", 
            paymentType: nil, 
            bankAccountName: nil,
            bankID: nil,
            bankAccountNumber: nil
        )
        isAuthenticating = true
        errorMessage = ""
        Task {
            do {
                if let _ = try? await FirebaseManager.shared.fetchUser(byEmail: email) {
                    await MainActor.run {
                        isAuthenticating = false
                        errorMessage = "Email already in use."
                    }
                    return
                }
                
                try await self.authViewModel.registerUserAsync(user: newUser, defaultCurrency: selectedCurrency)
                await MainActor.run {
                    if let user = self.authViewModel.currentUser {
                        self.viewModel.register(user: user, defaultCurrency: selectedCurrency)
                    }
                    self.isAuthenticating = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            } catch {
                await MainActor.run {
                    self.isAuthenticating = false
                    self.errorMessage = error.localizedDescription
                }
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
