import SwiftUI
import UIKit

struct GroupPaymentQRView: View {
    let group: Group
    let qrGenerator = QRCodeGenerator()
    
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var qrPayload: String = ""
    @State private var qrImageBase64: String? = nil
    @State private var isLoadingQR: Bool = false
    @State private var qrError: String? = nil
    
    // Payment amount
    // Payment amount
    @State private var amountString: String = ""
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Text("Pay Group Fund")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .neonGlow(Theme.primaryAccent, radius: 4)
                    .padding(.top, 10)
                
                if qrPayload.isEmpty && qrImageBase64 == nil {
                        Text("Enter the amount you want to add to \(group.name).")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 40)
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 16) {
                                IconBadge(systemName: "banknote", color: Theme.secondaryAccent)
                                TextField("Amount", text: $amountString)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(20)
                        }
                        .premiumCard(cornerRadius: 24, accentColor: Theme.primaryAccent)
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        GradientButton(label: "Generate QR", isEnabled: !amountString.isEmpty) {
                            generateQR()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    } else {
                        Text("Scan this QR code with your banking app.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 40)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Theme.cardBackground)
                                .shadow(color: Theme.primaryAccent.opacity(0.3), radius: 20)
                                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Theme.primaryAccent.opacity(0.4), lineWidth: 1.5))
                            
                            if isLoadingQR {
                                VStack(spacing: 16) {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.5)
                                    Text("Generating QR...")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            } else if let error = qrError {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Theme.dangerColor)
                                    Text(error)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Theme.dangerColor)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                            } else {
                                if let base64String = qrImageBase64,
                                   let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
                                   let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(20)
                                        .padding(10)
                                } else if !qrPayload.isEmpty {
                                    if qrPayload.hasPrefix("http") {
                                        AsyncImage(url: URL(string: qrPayload)) { phase in
                                            if let image = phase.image {
                                                image.resizable()
                                                    .scaledToFit()
                                                    .cornerRadius(20)
                                                    .padding(10)
                                            } else if phase.error != nil {
                                                Image(systemName: "xmark.octagon.fill")
                                                    .foregroundColor(Theme.dangerColor)
                                                    .font(.system(size: 64))
                                            } else {
                                                ProgressView().scaleEffect(1.5)
                                            }
                                        }
                                    } else {
                                        Image(uiImage: qrGenerator.generateQRCode(from: qrPayload))
                                            .interpolation(.none)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200)
                                            .padding(30)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: 320)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        Button(action: {
                            qrPayload = ""
                            qrImageBase64 = nil
                            amountString = ""
                        }) {
                            Text("Generate Another QR")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.primaryAccent)
                        }
                        .padding(.bottom, 30)
                    }
            } // end VStack
        } // end ZStack
    } // end body
    
    // MARK: - Actions
    
    private func generateQR() {
        guard let amount = Int(amountString), amount > 0 else { return }
        isLoadingQR = true
        qrError = nil
        
        Task {
            if let creator = group.members.first(where: { $0.id == group.creatorID && $0.paymentType == "PayOS" }) {
                    let orderCode = "\(Int(Date().timeIntervalSince1970) + Int.random(in: 1...1000))"
                    let info = orderCode
                    let bankID = creator.bankID ?? ""
                    let bankAccountNumber = creator.bankAccountNumber ?? ""
                    let accountName = creator.bankAccountName ?? ""
                    let encodedName = accountName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    
                    let urlString = "https://img.vietqr.io/image/\(bankID)-\(bankAccountNumber)-compact2.png?amount=\(amount)&addInfo=\(info)&accountName=\(encodedName)"
                    
                    await MainActor.run {
                        self.qrPayload = urlString
                        self.isLoadingQR = false
                    }
                    
                    // Start polling
                    var isPaid = false
                    for _ in 0..<120 { // 6 mins
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        if let matched = try? await CassoService.shared.verifyPayment(amount: Double(amount), orderCode: orderCode), matched {
                            isPaid = true
                            break
                        }
                    }
                    if isPaid {
                        await MainActor.run {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    await MainActor.run {
                        self.qrError = "No payment gateway configured for group."
                        self.isLoadingQR = false
                    }
                }
            }
        }
    }
