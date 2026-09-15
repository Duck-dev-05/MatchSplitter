import SwiftUI
import UIKit

struct GroupPaymentQRView: View {
    let group: Group
    let qrGenerator = QRCodeGenerator()
    
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var qrPayload: String = ""
    @State private var qrImageBase64: String? = nil
    @State private var isLoadingQR: Bool = true
    @State private var qrError: String? = nil
    
    // Configuration states
    @State private var bankBin: String = ""
    @State private var paymentAccountNo: String = ""
    @State private var bankAccountName: String = ""
    @State private var showingBankSelection = false
    @State private var banks: [VietQRBank] = []
    @State private var isLoadingBanks = false
    @State private var isConfigured: Bool = false
    
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
                
                Text(isConfigured ? "Pay Group Fund" : "Setup Group Payment")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .neonGlow(Theme.primaryAccent, radius: 4)
                    .padding(.top, 10)
                
                if !isConfigured {
                    Text("Configure your VietQR details to receive group funds.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 40)
                    
                    configurationForm
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    GradientButton(label: "Save & Generate QR", isEnabled: !bankBin.isEmpty && !paymentAccountNo.isEmpty) {
                        saveConfiguration()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                } else {
                    Text("Scan this VietQR code with your banking app to add funds to \(group.name).")
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
                    .frame(maxWidth: 320)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            bankBin = group.paymentBankBin ?? ""
            paymentAccountNo = group.paymentAccountNo ?? ""
            bankAccountName = group.paymentAccountName ?? ""
            
            if !bankBin.isEmpty && !paymentAccountNo.isEmpty {
                isConfigured = true
                generateQR(bin: bankBin, accountNo: paymentAccountNo, accountName: bankAccountName)
            } else {
                fetchBanks()
            }
        }
        .sheet(isPresented: $showingBankSelection) {
            BankSelectionView(banks: banks, selectedBankBin: $bankBin)
        }
    }
    
    // MARK: - Configuration Form
    private var configurationForm: some View {
        VStack(spacing: 0) {
            Button(action: { showingBankSelection = true }) {
                HStack(spacing: 16) {
                    IconBadge(systemName: "building.2.fill", color: Theme.secondaryAccent)
                    if isLoadingBanks {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Spacer()
                    } else {
                        HStack {
                            Text(banks.first(where: { $0.bin == bankBin })?.shortName ?? "Select Bank")
                                .foregroundColor(bankBin.isEmpty ? .white.opacity(0.5) : .white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
                .padding(20)
            }
            
            Divider().background(Color.white.opacity(0.08))
            
            HStack(spacing: 16) {
                IconBadge(systemName: "number", color: Theme.secondaryAccent)
                TextField("Account Number", text: $paymentAccountNo)
                    .keyboardType(.numberPad)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(20)
            
            Divider().background(Color.white.opacity(0.08))
            
            HStack(spacing: 16) {
                IconBadge(systemName: "person.text.rectangle", color: Theme.secondaryAccent)
                TextField("Account Name (Optional)", text: $bankAccountName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(20)
        }
        .premiumCard(cornerRadius: 24, accentColor: Theme.primaryAccent)
    }
    
    // MARK: - Actions
    private func fetchBanks() {
        Task {
            isLoadingBanks = true
            do {
                banks = try await VietQRService.shared.fetchBanks()
            } catch {
                print("Error fetching VietQR banks: \(error)")
            }
            isLoadingBanks = false
        }
    }
    
    private func saveConfiguration() {
        viewModel.updateGroup(
            id: group.id,
            name: group.name,
            currency: group.currency,
            paymentBankBin: bankBin,
            paymentAccountNo: paymentAccountNo,
            paymentAccountName: bankAccountName.isEmpty ? nil : bankAccountName
        )
        isConfigured = true
        generateQR(bin: bankBin, accountNo: paymentAccountNo, accountName: bankAccountName)
    }
    
    private func generateQR(bin: String, accountNo: String, accountName: String) {
        isLoadingQR = true
        Task {
            do {
                let info = "Fund for \(group.name)"
                let finalAccountName = accountName.isEmpty ? group.name.uppercased() : accountName
                
                let payload = try await VietQRService.shared.generatePayload(
                    accountNo: accountNo, 
                    accountName: finalAccountName, 
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
