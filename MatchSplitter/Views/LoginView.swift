import SwiftUI
import CoreData
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var session: SessionManager
    
    @State private var isLoginMode = true
    
    // Form State
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background gradient
                LinearGradient(
                    colors: [Theme.primary.opacity(0.7), Theme.secondary.opacity(0.5), Theme.dynamicBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating shapes
                Circle()
                    .fill(Theme.primary.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 50)
                    .offset(x: -100, y: -200)
                    
                Circle()
                    .fill(Theme.secondary.opacity(0.3))
                    .frame(width: 250, height: 250)
                    .blur(radius: 40)
                    .offset(x: 150, y: 300)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.spacingL) {
                        
                        // Header
                        VStack(spacing: Theme.spacingS) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                            
                            Text("MatchSplitter")
                                .font(.system(size: 38, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                            
                            Text("Your team. Your expenses. Sorted.")
                                .font(Typography.body())
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, Theme.spacingXL)
                        .padding(.bottom, Theme.spacingM)
                        
                        // Custom Segmented Picker
                        HStack(spacing: 0) {
                            Button(action: { withAnimation(.spring()) { isLoginMode = true } }) {
                                Text("Log In")
                                    .font(Typography.button())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isLoginMode ? Color.white : Color.clear)
                                    .foregroundColor(isLoginMode ? Theme.primary : .white)
                                    .cornerRadius(20)
                            }
                            
                            Button(action: { withAnimation(.spring()) { isLoginMode = false } }) {
                                Text("Register")
                                    .font(Typography.button())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(!isLoginMode ? Color.white : Color.clear)
                                    .foregroundColor(!isLoginMode ? Theme.primary : .white)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(4)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(24)
                        .padding(.horizontal, Theme.spacingL)
                        
                        // Main Form Card
                        VStack(spacing: Theme.spacingM) {
                            if !isLoginMode {
                                CustomTextField(icon: "person.fill", placeholder: "Full Name", text: $name)
                            }
                            
                            CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboardType: .emailAddress)
                            
                            CustomSecureField(icon: "lock.fill", placeholder: "Password", text: $password)
                            
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(Theme.error)
                                    .font(Typography.captionBold())
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }
                            
                            Button(action: handleAction) {
                                Text(isLoginMode ? "Sign In" : "Create Account")
                                    .font(Typography.button())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.gradientPrimary)
                                    .cornerRadius(Theme.radiusM)
                                    .shadow(color: Theme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.top, Theme.spacingS)
                        }
                        .padding(Theme.spacingL)
                        .background(.ultraThinMaterial)
                        .cornerRadius(Theme.radiusL)
                        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 10)
                        .padding(.horizontal, Theme.spacingL)
                        
                        // Divider
                        HStack {
                            VStack { Divider().background(Color.white.opacity(0.4)) }
                            Text("OR")
                                .font(Typography.captionBold())
                                .foregroundColor(.white.opacity(0.8))
                            VStack { Divider().background(Color.white.opacity(0.4)) }
                        }
                        .padding(.horizontal, Theme.spacingXL)
                        
                        // Google Button
                        Button(action: loginWithGoogle) {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 20))
                                Text("Continue with Google")
                            }
                            .font(Typography.button())
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(Theme.radiusM)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, Theme.spacingL)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func handleAction() {
        errorMessage = ""
        
        if isLoginMode {
            // Login Logic
            guard !email.isEmpty, !password.isEmpty else {
                errorMessage = "Please enter email and password."
                return
            }
            
            let req: NSFetchRequest<User> = User.fetchRequest()
            req.predicate = NSPredicate(format: "email == %@ AND password == %@", email.lowercased(), password)
            
            if let user = try? viewContext.fetch(req).first {
                withAnimation {
                    session.login(user: user)
                }
            } else {
                errorMessage = "Invalid email or password."
            }
            
        } else {
            // Register Logic
            guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
                errorMessage = "Please fill in all fields."
                return
            }
            
            // Check if email already exists
            let req: NSFetchRequest<User> = User.fetchRequest()
            req.predicate = NSPredicate(format: "email == %@", email.lowercased())
            if let _ = try? viewContext.fetch(req).first {
                errorMessage = "An account with this email already exists."
                return
            }
            
            let newUser = User(context: viewContext)
            newUser.id = UUID()
            newUser.username = name
            newUser.email = email.lowercased()
            newUser.password = password
            newUser.createdAt = Date()
            
            do {
                try viewContext.save()
                withAnimation {
                    session.login(user: newUser)
                }
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
                print("Error signing in: \(error.localizedDescription)")
                self.errorMessage = "Failed to sign in with Google."
                return
            }
            
            guard let user = signInResult?.user,
                  let profile = user.profile else {
                self.errorMessage = "Could not fetch Google profile."
                return
            }
            
            let email = profile.email
            let name = profile.name
            
            // Check if user already exists
            let req: NSFetchRequest<User> = User.fetchRequest()
            req.predicate = NSPredicate(format: "email == %@", email.lowercased())
            
            if let existingUser = try? viewContext.fetch(req).first {
                // Log in existing user
                withAnimation {
                    session.login(user: existingUser)
                }
            } else {
                // Register new user
                let newUser = User(context: viewContext)
                newUser.id = UUID()
                newUser.username = name
                newUser.email = email.lowercased()
                // No password needed for Google users, but we can set a dummy one or leave it empty if your model allows
                newUser.password = "GOOGLE_OAUTH_PLACEHOLDER"
                newUser.createdAt = Date()
                
                do {
                    try viewContext.save()
                    withAnimation {
                        session.login(user: newUser)
                    }
                } catch {
                    self.errorMessage = "Error creating account with Google."
                }
            }
        }
    }
}

// Utility to get the root view controller for presenting Google Sign-In
struct ApplicationUtility {
    static var rootViewController: UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
}

// Custom View Components for Premium UI
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.primary.opacity(0.8))
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(Theme.dynamicTextPrimary)
        }
        .padding()
        .background(Color(UIColor.systemBackground).opacity(0.7))
        .cornerRadius(Theme.radiusM)
    }
}

struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.primary.opacity(0.8))
                .frame(width: 24)
            
            SecureField(placeholder, text: $text)
                .foregroundColor(Theme.dynamicTextPrimary)
        }
        .padding()
        .background(Color(UIColor.systemBackground).opacity(0.7))
        .cornerRadius(Theme.radiusM)
    }
}
