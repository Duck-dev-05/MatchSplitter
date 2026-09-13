import SwiftUI

struct SettlementView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedSettlement: Settlement?
    @State private var appear = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                DragHandle()

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
                    .buttonStyle(PressableButtonStyle())
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
                    allSettledView
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(Array(settlements.enumerated()), id: \.offset) { index, settlement in
                                Button(action: { selectedSettlement = settlement }) {
                                    SettlementCardView(settlement: settlement, currency: group.currency)
                                }
                                .buttonStyle(PressableButtonStyle())
                                .offset(y: appear ? 0 : 20)
                                .opacity(appear ? 1 : 0)
                                .animation(
                                    .spring(response: 0.45, dampingFraction: 0.75)
                                    .delay(Double(index) * 0.07),
                                    value: appear
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
        .sheet(item: $selectedSettlement) { settlement in
            QRCodePaymentView(group: group, settlement: settlement, currency: group.currency)
                .halfSheetIfAvailable()
        }
        .onAppear { withAnimation { appear = true } }
    }

    private var allSettledView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Theme.successColor.opacity(0.12))
                    .frame(width: 120, height: 120)
                Circle()
                    .stroke(Theme.successColor.opacity(0.25), lineWidth: 1.5)
                    .frame(width: 138, height: 138)
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
    }
}

// MARK: - Settlement Card
struct SettlementCardView: View {
    var settlement: Settlement
    var currency: Currency

    @State private var arrowAnimate = false

    var body: some View {
        HStack(spacing: 14) {
            // From avatar
            GradientAvatar(
                name: settlement.fromUser.name,
                avatarURL: settlement.fromUser.avatarURL,
                size: 46,
                gradient: LinearGradient(
                    colors: [Theme.dangerColor, Theme.dangerColor.opacity(0.6)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )

            // Direction arrow + amount
            VStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.secondaryAccent.opacity(arrowAnimate ? 0.9 : 0.3))
                    .scaleEffect(arrowAnimate ? 1.15 : 1.0)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: arrowAnimate)
                Text("\(currency.symbol)\(String(format: "%.2f", settlement.amount))")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(Theme.dangerColor)
            }
            .onAppear { arrowAnimate = true }

            // To avatar
            GradientAvatar(
                name: settlement.toUser.name,
                avatarURL: settlement.toUser.avatarURL,
                size: 46,
                gradient: LinearGradient(
                    colors: [Theme.successColor, Theme.successColor.opacity(0.6)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
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
        .glassCard(cornerRadius: 20)
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
    var group: Group
    var settlement: Settlement
    var currency: Currency
    let generator = QRCodeGenerator()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: GroupViewModel
    
    @State private var qrPayload: String = ""
    @State private var qrImageBase64: String? = nil
    @State private var isLoadingQR: Bool = true
    @State private var qrError: String? = nil
    @State private var isPaymentSuccess: Bool = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            // Glow blobs
            Circle()
                .fill(Theme.primaryAccent.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: -80, y: -100)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                DragHandle()

                HStack {
                    if #available(iOS 16.0, *) {
                        Button(action: shareReceipt) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(Theme.secondaryAccent)
                                .font(.system(size: 20))
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
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

                    HStack(spacing: 12) {
                        GradientAvatar(
                            name: settlement.fromUser.name, avatarURL: settlement.fromUser.avatarURL, size: 36,
                            gradient: LinearGradient(
                                colors: [Theme.dangerColor, Theme.dangerColor.opacity(0.7)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        Image(systemName: "arrow.right")
                            .foregroundColor(Theme.secondaryAccent.opacity(0.70))
                        GradientAvatar(
                            name: settlement.toUser.name, avatarURL: settlement.toUser.avatarURL, size: 36,
                            gradient: LinearGradient(
                                colors: [Theme.successColor, Theme.successColor.opacity(0.7)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        Text(settlement.toUser.name)
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Text("\(currency.symbol)\(String(format: "%.2f", settlement.amount))")
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.primaryGradient)
                }
                .padding(.bottom, 32)

                ZStack {
                    // White card
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Theme.primaryAccent.opacity(0.45), radius: 40, x: 0, y: 18)
                        .frame(width: 290, height: 290)

                    if isLoadingQR {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Generating QR...")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 240, height: 240)
                    } else if isPaymentSuccess {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(Theme.successColor)
                            Text("Payment Received!")
                                .font(.headline)
                                .foregroundColor(Theme.successColor)
                        }
                        .frame(width: 240, height: 240)
                    } else if let base64 = qrImageBase64,
                              let data = Data(base64Encoded: base64),
                              let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 240, height: 240)
                    } else {
                        Image(uiImage: generator.generateQRCode(from: qrPayload))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 240, height: 240)
                    }

                    // Decorative corner brackets
                    qrCornerBrackets
                }
                .padding(.bottom, 28)

                if let pid = settlement.toUser.paymentID {
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
                    .glassCard(cornerRadius: 16)
                }

                Spacer()
            }
        }
        .onAppear {
            if settlement.toUser.paymentType == "PayOS",
               let clientId = settlement.toUser.payOSClientId,
               let apiKey = settlement.toUser.payOSApiKey,
               let checksumKey = settlement.toUser.payOSChecksumKey {
                Task {
                    do {
                        // Generate a unique order code less than 9007199254740991 (PayOS limit)
                        // Int(Date().timeIntervalSince1970) is around 1.7 billion, perfectly fine.
                        let orderCode = Int(Date().timeIntervalSince1970) + Int.random(in: 1...1000)
                        let info = "MatchSplitter"
                        let data = try await PayOSService.shared.createPaymentLink(
                            clientId: clientId, apiKey: apiKey, checksumKey: checksumKey,
                            amount: Int(settlement.amount), description: info, orderCode: orderCode
                        )
                        
                        await MainActor.run {
                            if let qr = data.qrCode {
                                self.qrPayload = qr
                            }
                            self.isLoadingQR = false
                        }
                        
                        // Start polling
                        var isPaid = false
                        for _ in 0..<120 { // 120 * 3 = 6 minutes timeout
                            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                            let info = try await PayOSService.shared.getPaymentInfo(clientId: clientId, apiKey: apiKey, orderCode: orderCode)
                            if info.status == "PAID" {
                                isPaid = true
                                break
                            }
                        }
                        
                        if isPaid {
                            await MainActor.run {
                                withAnimation {
                                    self.isPaymentSuccess = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    viewModel.addPayment(to: group, fromUser: settlement.fromUser, toUser: settlement.toUser, amount: settlement.amount)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    } catch {
                        await MainActor.run {
                            self.qrError = "Failed to load PayOS QR"
                            self.qrPayload = generator.generatePaymentPayload(paymentType: settlement.toUser.paymentType, paymentID: settlement.toUser.paymentID ?? "Unknown", amount: settlement.amount, currency: currency)
                            self.isLoadingQR = false
                        }
                    }
                }
            } else if currency == .vnd, settlement.toUser.paymentType == "VietQR", let bin = settlement.toUser.bankBin, let accountNo = settlement.toUser.paymentID {
                Task {
                    do {
                        let info = "MatchSplitter Settlement"
                        let accountName = settlement.toUser.bankAccountName?.isEmpty == false ? settlement.toUser.bankAccountName! : settlement.toUser.name.uppercased()
                        let payload = try await VietQRService.shared.generatePayload(
                            accountNo: accountNo, 
                            accountName: accountName, 
                            bin: bin, 
                            amount: settlement.amount, 
                            info: info
                        )
                        await MainActor.run {
                            self.qrPayload = payload.qrCode
                            self.qrImageBase64 = payload.qrDataURL.replacingOccurrences(of: "data:image/png;base64,", with: "")
                            self.isLoadingQR = false
                        }
                    } catch {
                        await MainActor.run {
                            self.qrError = "Failed to load VietQR"
                            self.qrPayload = generator.generatePaymentPayload(paymentType: settlement.toUser.paymentType, paymentID: settlement.toUser.paymentID ?? "Unknown", amount: settlement.amount, currency: currency)
                            self.isLoadingQR = false
                        }
                    }
                }
            } else {
                self.qrPayload = generator.generatePaymentPayload(paymentType: settlement.toUser.paymentType, paymentID: settlement.toUser.paymentID ?? "Unknown", amount: settlement.amount, currency: currency)
                self.isLoadingQR = false
            }
        }
    }

    // Decorative corner bracket overlay on the QR card
    private var qrCornerBrackets: some View {
        ZStack {
            // Top-left
            bracketCorner().offset(x: -125, y: -125)
            // Top-right
            bracketCorner().rotationEffect(.degrees(90)).offset(x: 125, y: -125)
            // Bottom-right
            bracketCorner().rotationEffect(.degrees(180)).offset(x: 125, y: 125)
            // Bottom-left
            bracketCorner().rotationEffect(.degrees(270)).offset(x: -125, y: 125)
        }
    }

    private func bracketCorner() -> some View {
        ZStack(alignment: .topLeading) {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 20))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 20, y: 0))
            }
            .stroke(Theme.primaryAccent, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
        .frame(width: 20, height: 20)
    }

    @available(iOS 16.0, *)
    @MainActor
    private func shareReceipt() {
        let receiptView = VStack(spacing: 20) {
            Text("MatchSplitter Receipt")
                .font(.title)
                .bold()
                .foregroundColor(Theme.primaryAccent)
            Text("\(settlement.fromUser.name) owes \(settlement.toUser.name)")
                .font(.headline)
                .foregroundColor(.white)
            Text("\(currency.symbol)\(String(format: "%.2f", settlement.amount))")
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.white)

            Image(uiImage: generator.generateQRCode(from: qrPayload))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
        .padding(40)
        .background(Theme.backgroundGradient)

        let renderer = ImageRenderer(content: receiptView)
        renderer.scale = UIScreen.main.scale

        if let uiImage = renderer.uiImage {
            let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true, completion: nil)
            }
        }
    }
}
