import SwiftUI

struct SettlementView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedSettlement: Settlement?

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 14)

                // Header Bar
                HStack {
                    Spacer()
                    Text("Settlements")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Theme.primaryAccent)
                    .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)

                let settlements = viewModel.calculateSettlements(for: group)

                if settlements.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 120, height: 120)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.green)
                        }
                        Text("All Settled Up!")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("Everyone is even. No payments needed.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(settlements) { settlement in
                                Button(action: { selectedSettlement = settlement }) {
                                    SettlementCardView(settlement: settlement)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(24)
                    }
                }
            }
        }
        .sheet(item: $selectedSettlement) { settlement in
            QRCodePaymentView(settlement: settlement)
        }
    }
}

// MARK: - Settlement Card

struct SettlementCardView: View {
    var settlement: Settlement

    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                HStack(spacing: 16) {
                    // From Avatar
                    AvatarBubble(name: settlement.fromUser.name, color: Color(red: 0.95, green: 0.37, blue: 0.54))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(settlement.fromUser.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        HStack(spacing: 4) {
                            Text("owes")
                                .foregroundColor(.white.opacity(0.5))
                            Text(settlement.toUser.name)
                                .foregroundColor(.white.opacity(0.8))
                                .fontWeight(.semibold)
                        }
                        .font(.caption)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text(String(format: "฿%.2f", settlement.amount))
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(red: 0.95, green: 0.37, blue: 0.54))

                        HStack(spacing: 4) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 10, weight: .bold))
                            Text("PAY NOW")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(Theme.secondaryAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.primaryAccent.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
                .padding(20)
            ),
            cornerRadius: 24
        )
    }
}

// MARK: - Avatar Bubble

struct AvatarBubble: View {
    var name: String
    var color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 48, height: 48)
            Text(name.prefix(1).uppercased())
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(color)
        }
    }
}

// MARK: - QR Code Payment View

struct QRCodePaymentView: View {
    var settlement: Settlement
    let generator = QRCodeGenerator()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 14)

                HStack {
                    Spacer()
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(Theme.primaryAccent)
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Spacer()

                VStack(spacing: 12) {
                    Text("SCAN TO PAY")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white.opacity(0.4))
                        .textCase(.uppercase)

                    Text(settlement.toUser.name)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Text(String(format: "฿%.2f", settlement.amount))
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.primaryAccent)
                }
                .padding(.bottom, 40)

                // QR Code Card
                let payload = generator.generatePaymentPayload(
                    paymentID: settlement.toUser.paymentID ?? "Unknown",
                    amount: settlement.amount
                )

                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white)
                        .shadow(color: Theme.primaryAccent.opacity(0.4), radius: 40, x: 0, y: 20)
                        .frame(width: 300, height: 300)

                    Image(uiImage: generator.generateQRCode(from: payload))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                }
                .padding(.bottom, 32)

                if let pid = settlement.toUser.paymentID {
                    Theme.applyGlassCard(
                        to: AnyView(
                            HStack(spacing: 8) {
                                Image(systemName: "creditcard.fill")
                                Text("ID: \(pid)")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        ),
                        cornerRadius: 16
                    )
                }

                Spacer()
            }
        }
    }
}
