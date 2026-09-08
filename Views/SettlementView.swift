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
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 38, height: 5)
                    .padding(.top, 14)

                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.55))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Settle Up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.secondaryAccent)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                let settlements = viewModel.calculateSettlements(for: group)

                if settlements.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Theme.successColor.opacity(0.12))
                                .frame(width: 120, height: 120)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 58))
                                .foregroundColor(Theme.successColor)
                        }
                        Text("All Settled Up!")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("Everyone is even. No payments needed.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.45))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(settlements) { settlement in
                                Button(action: { selectedSettlement = settlement }) {
                                    SettlementCardView(settlement: settlement, currency: group.currency)
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
            QRCodePaymentView(settlement: settlement, currency: group.currency)
        }
    }
}

// MARK: - Settlement Card
struct SettlementCardView: View {
    var settlement: Settlement
    var currency: Currency

    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                HStack(spacing: 14) {
                    // From avatar
                    GradientAvatar(
                        name: settlement.fromUser.name,
                        size: 46,
                        gradient: LinearGradient(colors: [Theme.dangerColor, Theme.dangerColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                    // Direction arrow
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.25))
                        Text("\(currency.symbol)\(String(format: "%.2f", settlement.amount))")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(Theme.dangerColor)
                    }

                    // To avatar
                    GradientAvatar(
                        name: settlement.toUser.name,
                        size: 46,
                        gradient: LinearGradient(colors: [Theme.successColor, Theme.successColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 4) {
                            Text(settlement.fromUser.name)
                                .fontWeight(.semibold)
                            Text("→")
                                .foregroundColor(.white.opacity(0.35))
                            Text(settlement.toUser.name)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        Text("Tap to generate QR")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.35))
                    }

                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Theme.primaryAccent.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "qrcode")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.primaryAccent)
                    }
                }
                .padding(16)
            ),
            cornerRadius: 20
        )
    }
}

// MARK: - Avatar Bubble (kept for compatibility)
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

// MARK: - QR Payment View
struct QRCodePaymentView: View {
    var settlement: Settlement
    var currency: Currency
    let generator = QRCodeGenerator()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 38, height: 5)
                    .padding(.top, 14)

                HStack {
                    Spacer()
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(Theme.secondaryAccent)
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                Spacer()

                // Amount display
                VStack(spacing: 10) {
                    Text("SCAN TO PAY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.40))
                        .textCase(.uppercase)
                        .tracking(1.5)

                    HStack(spacing: 12) {
                        GradientAvatar(name: settlement.fromUser.name, size: 36,
                            gradient: LinearGradient(colors: [Theme.dangerColor, Theme.dangerColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white.opacity(0.30))
                        GradientAvatar(name: settlement.toUser.name, size: 36,
                            gradient: LinearGradient(colors: [Theme.successColor, Theme.successColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Text(settlement.toUser.name)
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Text("\(currency.symbol)\(String(format: "%.2f", settlement.amount))")
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.primaryAccent)
                }
                .padding(.bottom, 32)

                // QR Card
                let payload = generator.generatePaymentPayload(
                    paymentID: settlement.toUser.paymentID ?? "Unknown",
                    amount: settlement.amount
                )

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Theme.primaryAccent.opacity(0.45), radius: 40, x: 0, y: 18)
                        .frame(width: 290, height: 290)

                    Image(uiImage: generator.generateQRCode(from: payload))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                }
                .padding(.bottom, 28)

                if let pid = settlement.toUser.paymentID {
                    Theme.applyGlassCard(
                        to: AnyView(
                            HStack(spacing: 8) {
                                Image(systemName: "creditcard.fill")
                                    .foregroundColor(Theme.secondaryAccent)
                                Text("ID: \(pid)")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.80))
                            }
                            .font(.system(size: 14))
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
