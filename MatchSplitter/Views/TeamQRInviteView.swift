import SwiftUI
import CoreData

struct TeamInviteData: Codable {
    var type:      String = "teamInvite"
    var groupID:   String
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
                // Dark gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.12, blue: 0.08),
                        Color(red: 0.02, green: 0.07, blue: 0.05)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Subtle glow orb
                Circle()
                    .fill(Theme.primary.opacity(0.25))
                    .frame(width: 350, height: 350)
                    .blur(radius: 60)
                    .offset(x: 0, y: -80)

                VStack(spacing: Theme.spacingXL) {

                    // ── Title ──
                    VStack(spacing: Theme.spacingS) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Theme.accent)

                        Text("Team Invite")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        Text("Have players scan to join **\(group.name)**.\nRefreshes every 5 minutes for security.")
                            .font(Typography.caption())
                            .foregroundColor(.white.opacity(0.60))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacingXL)
                    }

                    // ── QR Glass Card ──
                    VStack(spacing: Theme.spacingL) {
                        if !qrString.isEmpty, let qrImage = QRGenerator.generateQRCode(from: qrString) {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220, height: 220)
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(Theme.radiusXL)
                                .shadow(color: Theme.primary.opacity(0.3), radius: 20, x: 0, y: 8)
                        } else {
                            RoundedRectangle(cornerRadius: Theme.radiusXL)
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 260, height: 260)
                                .overlay(ProgressView().tint(Theme.accent))
                        }

                        // ── Countdown ──
                        HStack(spacing: 10) {
                            // Animated ring
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 3)
                                    .frame(width: 28, height: 28)
                                Circle()
                                    .trim(from: 0, to: CGFloat(timeRemaining) / 300)
                                    .stroke(
                                        timeRemaining < 60 ? Theme.error : Theme.accent,
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                    )
                                    .frame(width: 28, height: 28)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 1), value: timeRemaining)
                            }

                            Text("Refreshes in \(timeString(time: timeRemaining))")
                                .font(Typography.captionBold())
                                .foregroundColor(timeRemaining < 60 ? Theme.error : Theme.accent)
                        }
                        .padding(.horizontal, Theme.spacingL)
                        .padding(.vertical, Theme.spacingS)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(Theme.radiusXL)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusXL)
                                .stroke(Color.white.opacity(0.12), lineWidth: 0.75)
                        )
                    }
                    .padding(Theme.spacingXL)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(Theme.radiusXXL)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusXXL)
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.75)
                    )
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, Theme.spacingL)
            }
            .navigationTitle("Invite Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.accent)
                        .font(Typography.bodyBold())
                }
            }
            .onAppear { generateNewInviteCode() }
            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    generateNewInviteCode()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func generateNewInviteCode() {
        let expirationDate = Date().addingTimeInterval(300)
        let inviteData = TeamInviteData(
            groupID:   group.id.uuidString,
            groupName: group.name,
            expiresAt: expirationDate.timeIntervalSince1970
        )
        if let data       = try? JSONEncoder().encode(inviteData),
           let stringData = String(data: data, encoding: .utf8) {
            self.qrString     = stringData
            self.timeRemaining = 300
        }
    }

    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
