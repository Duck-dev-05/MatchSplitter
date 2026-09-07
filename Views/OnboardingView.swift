import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var name = ""
    @State private var paymentID = ""
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.indigo.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "square.grid.2x2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.indigo)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5), value: isAnimating)
                
                VStack(spacing: 10) {
                    Text("Welcome to MatchSplitter")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Split expenses seamlessly and generate QR codes to settle debts instantly.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 20) {
                    CustomTextField(icon: "person.fill", placeholder: "Your Name", text: $name)
                    CustomTextField(icon: "qrcode.viewfinder", placeholder: "Payment ID (e.g. Phone Number)", text: $paymentID)
                }
                .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        viewModel.completeOnboarding(name: name, paymentID: paymentID)
                    }
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.indigo, .purple]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(color: .indigo.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .disabled(name.isEmpty || paymentID.isEmpty)
                .opacity(name.isEmpty || paymentID.isEmpty ? 0.5 : 1.0)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.indigo)
                .frame(width: 30)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
