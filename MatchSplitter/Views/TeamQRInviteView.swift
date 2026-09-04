import SwiftUI
import CoreData

struct TeamInviteData: Codable {
    var type: String = "teamInvite"
    var groupID: String
    var groupName: String
    var expiresAt: TimeInterval
}

struct TeamQRInviteView: View {
    @Environment(\.dismiss) private var dismiss
    let group: BusinessGroup
    
    @State private var timeRemaining = 300
    @State private var qrString: String = ""
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()
                
                VStack(spacing: Theme.spacingL) {
                    Text("Team Invite QR")
                        .font(.system(.title, design: .rounded).bold())
                        .foregroundColor(Theme.dynamicTextPrimary)
                    
                    Text("Have players scan this code to instantly join **\(group.name)**. For security, this code changes every 5 minutes.")
                        .font(Typography.body())
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacingXL)
                    
                    VStack(spacing: Theme.spacingM) {
                        if !qrString.isEmpty, let qrImage = QRGenerator.generateQRCode(from: qrString) {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 250, height: 250)
                                .cornerRadius(16)
                                .overlay(ProgressView())
                        }
                        
                        // Timer Display
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(timeRemaining < 60 ? Theme.error : Theme.primary)
                            Text("Refreshes in \(timeString(time: timeRemaining))")
                                .font(Typography.bodyBold())
                                .foregroundColor(timeRemaining < 60 ? Theme.error : Theme.primary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(timeRemaining < 60 ? Theme.error.opacity(0.1) : Theme.primary.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .padding(.top, Theme.spacingL)
                    
                    Spacer()
                }
                .padding(.top, Theme.spacingL)
            }
            .navigationTitle("Invite Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                generateNewInviteCode()
            }
            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    generateNewInviteCode()
                }
            }
        }
    }
    
    private func generateNewInviteCode() {
        let expirationDate = Date().addingTimeInterval(300) // 5 minutes from now
        let inviteData = TeamInviteData(
            groupID: group.id.uuidString,
            groupName: group.name,
            expiresAt: expirationDate.timeIntervalSince1970
        )
        
        if let data = try? JSONEncoder().encode(inviteData),
           let stringData = String(data: data, encoding: .utf8) {
            self.qrString = stringData
            self.timeRemaining = 300
        }
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
