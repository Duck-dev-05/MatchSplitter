import SwiftUI
import CoreData
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var session: SessionManager

    @State private var isLoginMode = true
    @State private var email    = ""
    @State private var password = ""
    @State private var name     = ""
    @State private var errorMessage = ""

    // Animated blob offsets
    @State private var blob1Offset: CGSize = CGSize(width: -80, height: -180)
    @State private var blob2Offset: CGSize = CGSize(width: 130,  height: 280)
    @State private var blob3Offset: CGSize = CGSize(width: 80,   height: -80)

    var body: some View {
        NavigationView {
            ZStack {
                // ── Aurora Background ──
                Color(UIColor.systemBackground).ignoresSafeArea()

                // Blob 1 — primary
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.primary.opacity(0.65), Theme.primary.opacity(0)],
                            center: .center, startRadius: 10, endRadius: 220
                        )
                    )
                    .frame(width: 420, height: 420)
                    .offset(blob1Offset)
                    .blur(radius: 30)

                // Blob 2 — accent
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.accent.opacity(0.45), Theme.accent.opacity(0)],
                            center: .center, startRadius: 10, endRadius: 180
                        )
                    )
                    .frame(width: 340, height: 340)
                    .offset(blob2Offset)
                    .blur(radius: 30)

                // Blob 3 — secondary
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.secondary.opacity(0.40), Theme.secondary.opacity(0)],
                            center: .center, startRadius: 10, endRadius: 160
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(blob3Offset)
                    .blur(radius: 28)

                // ── Content ──
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.spacingL) {

                        // Brand Header
                        VStack(spacing: Theme.spacingS) {
                            ZStack {
                                Circle()
                                    .fill(Theme.gradientPrimary)
                                    .frame(width: 90, height: 90)
                                    .shadow(color: Theme.primary.opacity(0.5), radius: 20, x: 0, y: 8)
                                Image(systemName: "sportscourt.fill")
                                    .font(.system(size: 38, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text("MatchSplitter")
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundColor(Theme.dynamicTextPrimary)

                            Text("Your team. Your expenses. Sorted.")
                                .font(Typography.caption())
                                .foregroundColor(Theme.dynamicTextSecondary)
                        }
                        .padding(.top, Theme.spacingXXL)
                        .padding(.bottom, Theme.spacingM)

                        // ── Segmented Picker ──
                        HStack(spacing: 0) {
                            tabButton("Log In",   isActive: isLoginMode)   { withAnimation(.spring(response: 0.35)) { isLoginMode = true } }
                            tabButton("Register", isActive: !isLoginMode)  { withAnimation(.spring(response: 0.35)) { isLoginMode = false } }
                        }
                        .padding(4)
                        .background(Theme.dynamicCardBackground)
                        .cornerRadius(Theme.radiusXL)
                        .padding(.horizontal, Theme.spacingL)

                        // ── Form Card ──
                        VStack(spacing: Theme.spacingM) {
                            if !isLoginMode {
                                CustomTextField(icon: "person.fill", placeholder: "Full Name", text: $name)
                            }
                            CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboardType: .emailAddress)
                            CustomSecureField(icon: "lock.fill", placeholder: "Password", text: $password)

                            if !errorMessage.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text(errorMessage)
                                }
                                .font(Typography.caption())
                                .foregroundColor(Theme.error)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            }

                            Button(action: handleAction) {
                                Text(isLoginMode ? "Sign In" : "Create Account")
                                    .font(Typography.button())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.gradientPrimary)
                                    .cornerRadius(Theme.radiusXL)
                                    .shadow(color: Theme.primary.opacity(0.35), radius: 12, x: 0, y: 5)
                            }
                            .padding(.top, 4)
                        }
                        .padding(Theme.spacingL)
                        .glassCard()
                        .padding(.horizontal, Theme.spacingL)

                        // ── Divider ──
                        HStack {
                            Rectangle()
                                .fill(Theme.border.opacity(0.5))
                                .frame(height: 0.5)
                            Text("OR")
                                .font(Typography.captionBold())
                                .foregroundColor(Theme.dynamicTextSecondary)
                                .padding(.horizontal, 8)
                            Rectangle()
                                .fill(Theme.border.opacity(0.5))
                                .frame(height: 0.5)
                        }
                        .padding(.horizontal, Theme.spacingXL)

                        // ── Google Sign In ──
                        Button(action: loginWithGoogle) {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Theme.primary)
                                Text("Continue with Google")
                                    .font(Typography.button())
                                    .foregroundColor(Theme.dynamicTextPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.dynamicCardBackground)
                            .cornerRadius(Theme.radiusXL)
                            .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 4)
                        }
                        .padding(.horizontal, Theme.spacingL)

                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear { animateBlobs() }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func tabButton(_ label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(Typography.button())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isActive ? Theme.primary : Color.clear)
                .foregroundColor(isActive ? .white : Theme.dynamicTextSecondary)
                .cornerRadius(Theme.radiusXL - 4)
        }
    }

    private func animateBlobs() {
        withAnimation(
            .easeInOut(duration: 7).repeatForever(autoreverses: true)
        ) {
            blob1Offset = CGSize(width: 100, height: -120)
        }
        withAnimation(
            .easeInOut(duration: 9).repeatForever(autoreverses: true)
        ) {
            blob2Offset = CGSize(width: -110, height: 200)
        }
        withAnimation(
            .easeInOut(duration: 6).repeatForever(autoreverses: true)
        ) {
            blob3Offset = CGSize(width: -60, height: 100)
        }
    }

    // MARK: - Auth Logic (unchanged)

    private func handleAction() {
        errorMessage = ""

        if isLoginMode {
            guard !email.isEmpty, !password.isEmpty else {
                errorMessage = "Please enter email and password."
                return
            }
            let req: NSFetchRequest<User> = User.fetchRequest()
            req.predicate = NSPredicate(format: "email == %@ AND password == %@", email.lowercased(), password)
            if let user = try? viewContext.fetch(req).first {
                withAnimation { session.login(user: user, context: viewContext) }
            } else {
                errorMessage = "Invalid email or password."
            }
        } else {
            guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
                errorMessage = "Please fill in all fields."
                return
            }
            let req: NSFetchRequest<User> = User.fetchRequest()
            req.predicate = NSPredicate(format: "email == %@", email.lowercased())
            if (try? viewContext.fetch(req).first) != nil {
                errorMessage = "An account with this email already exists."
                return
            }
            let newUser = User(context: viewContext)
            newUser.id = UUID()
            newUser.username = name
            newUser.email = email.lowercased()
            newUser.password = password
            newUser.createdAt = Date()

            let defaultGroup = BusinessGroup(context: viewContext)
            defaultGroup.id = UUID()
            defaultGroup.name = "My Team"
            defaultGroup.ownerID = newUser.id
            defaultGroup.createdAt = Date()

            do {
                try viewContext.save()
                withAnimation { session.login(user: newUser, context: viewContext) }
            } catch {
                errorMessage = "Error creating account. Please try again."
            }
        }
    }

    private func loginWithGoogle() {
        errorMessage = ""
        let rootVC = ApplicationUtility.rootViewController
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                self.errorMessage = "Failed to sign in with Google."
                return
            }
            guard let user = signInResult?.user, let profile = user.profile else {
                self.errorMessage = "Could not fetch Google profile."
                return
            }
            let email = profile.email
            let name  = profile.name
            let req: NSFetchRequest<User> = User.fetchRequest()
            req.predicate = NSPredicate(format: "email == %@", email.lowercased())
            if let existing = try? viewContext.fetch(req).first {
                withAnimation { session.login(user: existing, context: viewContext) }
            } else {
                let newUser = User(context: viewContext)
                newUser.id = UUID()
                newUser.username = name
                newUser.email = email.lowercased()
                newUser.password = "GOOGLE_OAUTH_PLACEHOLDER"
                newUser.createdAt = Date()

                let defaultGroup = BusinessGroup(context: viewContext)
                defaultGroup.id = UUID()
                defaultGroup.name = "My Team"
                defaultGroup.ownerID = newUser.id
                defaultGroup.createdAt = Date()

                do {
                    try viewContext.save()
                    withAnimation { session.login(user: newUser, context: viewContext) }
                } catch {
                    self.errorMessage = "Error creating account with Google."
                }
            }
        }
    }
}

// MARK: - ApplicationUtility

struct ApplicationUtility {
    static var rootViewController: UIViewController {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root  = scene.windows.first?.rootViewController else { return .init() }
        return root
    }
}

// MARK: - Custom Field Components

struct CustomTextField: View {
    let icon:        String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Theme.primary)
                .frame(width: 22)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(Typography.body())
                .foregroundColor(Theme.dynamicTextPrimary)
        }
        .padding(Theme.spacingM)
        .background(Theme.dynamicBackground.opacity(0.85))
        .cornerRadius(Theme.radiusM)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusM)
                .stroke(Theme.border.opacity(0.25), lineWidth: 0.75)
        )
    }
}

struct CustomSecureField: View {
    let icon:        String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Theme.primary)
                .frame(width: 22)

            SecureField(placeholder, text: $text)
                .font(Typography.body())
                .foregroundColor(Theme.dynamicTextPrimary)
        }
        .padding(Theme.spacingM)
        .background(Theme.dynamicBackground.opacity(0.85))
        .cornerRadius(Theme.radiusM)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusM)
                .stroke(Theme.border.opacity(0.25), lineWidth: 0.75)
        )
    }
}
