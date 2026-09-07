import SwiftUI

struct SettlementView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedSettlement: Settlement?

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.14),
                    Color(red: 0.10, green: 0.08, blue: 0.22)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 5)
                    .padding(.top, 14)

                // Header Bar
                HStack {
                    Spacer()
                    Text("Settlements")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 0.63, green: 0.46, blue: 0.98))
                    .font(.system(size: 15, weight: .semibold))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                let settlements = viewModel.calculateSettlements(for: group)

                if settlements.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 100, height: 100)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 54))
                                .foregroundColor(.green)
                        }
                        Text("All Settled Up!")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Everyone is even. No payments needed.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.45))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(settlements) { settlement in
                                Button(action: { selectedSettlement = settlement }) {
                                    SettlementCardView(settlement: settlement)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(20)
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
        HStack(spacing: 14) {
            // From Avatar
            AvatarBubble(name: settlement.fromUser.name, color: Color(red: 0.95, green: 0.37, blue: 0.54))

            VStack(alignment: .leading, spacing: 3) {
                Text(settlement.fromUser.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                HStack(spacing: 4) {
                    Text("owes")
                        .foregroundColor(.white.opacity(0.4))
                    Text(settlement.toUser.name)
                        .foregroundColor(.white.opacity(0.7))
                }
                .font(.caption)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "฿%.2f", settlement.amount))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.95, green: 0.37, blue: 0.54))

                HStack(spacing: 3) {
                    Image(systemName: "qrcode")
                        .font(.caption2)
                    Text("Tap to pay")
                        .font(.caption2)
                }
                .foregroundColor(Color(red: 0.63, green: 0.46, blue: 0.98))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.14, green: 0.13, blue: 0.24))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
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
                .frame(width: 44, height: 44)
            Text(name.prefix(1).uppercased())
                .font(.system(size: 16, weight: .bold, design: .rounded))
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
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.14),
                    Color(red: 0.10, green: 0.08, blue: 0.22)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag Handle + Header
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 5)
                    .padding(.top, 14)

                HStack {
                    Spacer()
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(Color(red: 0.63, green: 0.46, blue: 0.98))
                        .font(.system(size: 15, weight: .semibold))
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                VStack(spacing: 8) {
                    Text("Pay to")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.45))
                        .textCase(.uppercase)


                    Text(settlement.toUser.name)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Text(String(format: "฿%.2f", settlement.amount))
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.63, green: 0.46, blue: 0.98))
                }
                .padding(.bottom, 30)

                // QR Code Card
                let payload = generator.generatePaymentPayload(
                    paymentID: settlement.toUser.paymentID ?? "Unknown",
                    amount: settlement.amount
                )

                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white)
                        .shadow(color: Color(red: 0.43, green: 0.26, blue: 0.98).opacity(0.3), radius: 30, x: 0, y: 15)
                        .frame(width: 280, height: 280)

                    Image(uiImage: generator.generateQRCode(from: payload))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230, height: 230)
                }
                .padding(.bottom, 24)

                if let pid = settlement.toUser.paymentID {
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.fill")
                            .font(.caption)
                        Text("Payment ID: \(pid)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white.opacity(0.4))
                }

                Spacer()
            }
        }
    }
}
