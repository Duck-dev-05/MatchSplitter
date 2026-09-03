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
                Theme.dynamicBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacingL) {
                        Text("MatchSplitter")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .padding(.top, Theme.spacingXL)
                        
                        Picker("Mode", selection: $isLoginMode) {
                            Text("Log In").tag(true)
                            Text("Register").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, Theme.spacingL)
                        
                        VStack(spacing: Theme.spacingM) {
                            if !isLoginMode {
                                TextField("Full Name", text: $name)
                                    .textFieldStyle(.roundedBorder)
                                    .textContentType(.name)
                            }
                            
                            TextField("Email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(.roundedBorder)
                            
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(Theme.error)
                                    .font(Typography.caption())
                            }
                            
                            Button(action: handleAction) {
                                Text(isLoginMode ? "Log In" : "Create Account")
                                    .font(Typography.button())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.gradientPrimary)
                                    .cornerRadius(Theme.radiusM)
                            }
                            .padding(.top, Theme.spacingS)
                        }
                        .padding(Theme.spacingL)
                        .cardStyle()
                        .padding(.horizontal)
                        
                        HStack {
                            VStack { Divider() }
                            Text("OR")
                                .font(Typography.caption())
                                .foregroundColor(Theme.dynamicTextSecondary)
                            VStack { Divider() }
                        }
                        .padding(.horizontal, Theme.spacingXL)
                        
                        Button(action: loginWithGoogle) {
                            HStack {
                                Image(systemName: "envelope.fill") // Can be replaced with Google logo
                                Text("Continue with Google")
                            }
                            .font(Typography.button())
                            .foregroundColor(Theme.dynamicTextPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.dynamicCardBackground)
                            .cornerRadius(Theme.radiusM)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, Theme.spacingL)
                        
                        Spacer()
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
                  let profile = user.profile,
                  let email = profile.email else {
                self.errorMessage = "Could not fetch Google profile."
                return
            }
            
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
