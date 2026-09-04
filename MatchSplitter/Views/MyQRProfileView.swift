import SwiftUI

struct QRProfileData: Codable {
    var name:  String
    var email: String
}

struct MyQRProfileView: View {
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()

                VStack(spacing: Theme.spacingXL) {
                    // ── Description ──
                    VStack(spacing: Theme.spacingS) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Theme.primary)

                        Text("Your Player QR")
                            .font(Typography.headline())

                        Text("Have teammates scan this to instantly add you to their roster.")
                            .font(Typography.caption())
                            .foregroundColor(Theme.dynamicTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacingXL)
                    }

                    // ── QR Card ──
                    VStack(spacing: Theme.spacingL) {
                        if let qrImage = generateQRCode() {
                            Image(uiImage: qrImage)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 230, height: 230)
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(Theme.radiusXL)
                                .shadow(color: Theme.primary.opacity(0.2), radius: 16, x: 0, y: 8)
                        } else {
                            RoundedRectangle(cornerRadius: Theme.radiusXL)
                                .fill(Theme.dynamicCardBackground)
                                .frame(width: 270, height: 270)
                                .overlay(
                                    Text("Could not generate QR")
                                        .font(Typography.caption())
                                        .foregroundColor(Theme.error)
                                )
                        }

                        // ── User Info ──
                        if let user = session.currentUser {
                            VStack(spacing: 4) {
                                Text(user.username)
                                    .font(Typography.bodyBold())
                                    .foregroundColor(Theme.dynamicTextPrimary)
                                if let email = user.email {
                                    Text(email)
                                        .font(Typography.caption())
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }
                            }
                        }
                    }
                    .padding(Theme.spacingXL)
                    .background(Theme.dynamicCardBackground)
                    .cornerRadius(Theme.radiusXXL)
                    .shadow(color: Color.black.opacity(0.07), radius: 16, x: 0, y: 6)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, Theme.spacingL)
            }
            .navigationTitle("My QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(Typography.bodyBold())
                        .foregroundColor(Theme.primary)
                }
            }
        }
    }

    func generateQRCode() -> UIImage? {
        guard let user = session.currentUser else { return nil }
        let profile = QRProfileData(name: user.username, email: user.email ?? "")
        guard let data       = try? JSONEncoder().encode(profile),
              let stringData = String(data: data, encoding: .utf8) else { return nil }
        return QRGenerator.generateQRCode(from: stringData)
    }
}
