import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var isSent = false
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Theme.primaryAccent.opacity(0.2))
                            .frame(width: 80, height: 80)
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(Theme.primaryAccent)
                    }
                    .padding(.bottom, 8)
                    
                    Text("Reset Password")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Enter the email address associated with your account, and we'll send you a link to reset your password.")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                if isSent {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.successColor)
                        Text("Reset link sent!")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Check your email for instructions.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 20)
                    .transition(.opacity)
                } else {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            IconBadge(systemName: "envelope.fill", color: Theme.secondaryAccent, size: 36, iconSize: 14)
                            TextField("Email Address", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                        GradientButton(label: "Send Reset Link", isEnabled: !email.isEmpty) {
                            withAnimation {
                                isSent = true
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}
