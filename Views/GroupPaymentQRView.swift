import SwiftUI

struct GroupPaymentQRView: View {
    let group: Group
    let qrGenerator = QRCodeGenerator()
    
    @State private var qrPayload: String = ""
    @State private var qrImageBase64: String? = nil
    @State private var isLoadingQR: Bool = true
    @State private var qrError: String? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Pay Group Fund")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .padding(.top, 40)
            
            Text("Scan this VietQR code with your banking app to add funds to \(group.name).")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Theme.cardBackground)
                    .shadow(color: Theme.primaryAccent.opacity(0.3), radius: 20)
                
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
            .frame(width: 280, height: 280)
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .onAppear {
            generateQR()
        }
    }
    
    private func generateQR() {
        guard let bin = group.paymentBankBin, let accountNo = group.paymentAccountNo, !bin.isEmpty, !accountNo.isEmpty else {
            qrError = "Group Payment Info is not set. The group creator must configure it in Group Settings."
            isLoadingQR = false
            return
        }
        
        Task {
            do {
                let info = "Fund for \(group.name)"
                let accountName = group.paymentAccountName?.isEmpty == false ? group.paymentAccountName! : group.name.uppercased()
                
                let payload = try await VietQRService.shared.generatePayload(
                    accountNo: accountNo, 
                    accountName: accountName, 
                    bin: bin, 
                    amount: 0, 
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
                    self.isLoadingQR = false
                }
            }
        }
    }
}
