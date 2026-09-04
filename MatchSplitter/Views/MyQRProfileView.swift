import SwiftUI

struct QRProfileData: Codable {
    var name: String
    var email: String
}

struct MyQRProfileView: View {
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Your Profile QR")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Have your friends scan this code to easily add you to their team.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if let qrImage = generateQRCode() {
                Image(uiImage: qrImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 10)
            } else {
                Text("Could not generate QR Code")
                    .foregroundColor(.red)
            }
            
            if let user = session.currentUser {
                VStack(spacing: 8) {
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.semibold)
                    if let email = user.email {
                        Text(email)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("My QR Code")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func generateQRCode() -> UIImage? {
        guard let user = session.currentUser else { return nil }
        
        let profile = QRProfileData(name: user.username, email: user.email ?? "")
        
        guard let data = try? JSONEncoder().encode(profile),
              let stringData = String(data: data, encoding: .utf8) else { return nil }
        
        return QRGenerator.generateQRCode(from: stringData)
    }
}
