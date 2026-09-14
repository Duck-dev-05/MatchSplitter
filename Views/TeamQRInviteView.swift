import SwiftUI
import UIKit

struct TeamQRInviteView: View {
    let group: Group
    let qrGenerator = QRCodeGenerator()
    
    var invitePayload: String {
        return "matchsplitter://join?id=\(group.id.uuidString)"
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Invite to \(group.name)")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .padding(.top, 40)
            
            Text("Have your friends scan this QR code with their camera to instantly join the team.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Theme.cardBackground)
                    .shadow(color: Theme.primaryAccent.opacity(0.3), radius: 20)
                
                Image(uiImage: qrGenerator.generateQRCode(from: invitePayload))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(30)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            .frame(width: 280, height: 280)
            .padding(.top, 20)
            
            Button(action: {
                shareLink()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .bold))
                    Text("Share Invite Link")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.secondaryAccent.opacity(0.15))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.secondaryAccent.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, 40)
            .padding(.top, 10)
            
            Spacer()
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Team Invite")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @MainActor
    private func shareLink() {
        let text = "Join my MatchSplitter group '\(group.name)'! Use this link to join: matchsplitter://join?id=\(group.id.uuidString)"
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            
            var topVC = rootVC
            while let presentedVC = topVC.presentedViewController {
                topVC = presentedVC
            }
            
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = topVC.view
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            topVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

