import SwiftUI

struct TeamQRInviteView: View {
    let group: Group
    let qrGenerator = QRCodeGenerator()
    
    var invitePayload: String {
        return "MATCHSPLITTER|JOIN|\(group.id.uuidString)"
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
                    .fill(Theme.surfaceCard)
                    .shadow(color: Theme.accent.opacity(0.3), radius: 20)
                
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
            
            Spacer()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Team Invite")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TeamQRInviteView_Previews: PreviewProvider {
    static var previews: some View {
        TeamQRInviteView(group: Group(name: "Sunday Football", creatorID: UUID()))
    }
}
