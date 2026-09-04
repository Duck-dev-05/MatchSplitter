import SwiftUI

struct InvoiceReceiptView: View {
    let invoice: Invoice
    let clientName: String
    let group: BusinessGroup
    let balanceDue: Double
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text(group.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Match Receipt")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .textCase(.uppercase)
            }
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
            .background(Theme.gradientPrimary)
            
            // Details
            VStack(spacing: 20) {
                HStack {
                    Text("Player")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(clientName)
                        .font(Typography.bodyBold())
                }
                
                HStack {
                    Text("Date")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(invoice.issueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(Typography.bodyBold())
                }
                
                HStack {
                    Text("Invoice")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(invoice.invoiceNumber)
                        .font(Typography.bodyBold())
                }
                
                Divider()
                
                // Total
                VStack(spacing: 8) {
                    Text("Total Due")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(balanceDue.formatted(.currency(code: "VND")))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.primary)
                }
                .padding(.vertical, 16)
                
                Divider()
                
                // QR Code
                if let bank = group.bankName, !bank.isEmpty,
                   let accNum = group.accountNumber, !accNum.isEmpty {
                    VStack(spacing: 12) {
                        Text("Scan to Pay")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        let qrString = "Bank: \(bank)\nAccount: \(accNum)\nName: \(group.accountName ?? "")\nAmount: \(Int(balanceDue))\nRef: \(invoice.invoiceNumber)"
                        
                        if let qrImage = QRGenerator.generateQRCode(from: qrString) {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        Text("\(bank) - \(accNum)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 16)
                }
            }
            .padding(32)
            .background(Color.white)
            
            // Footer
            Text("Powered by MatchSplitter")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGroupedBackground))
        }
        .frame(width: 400) // Fixed width for consistent image rendering
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .background(Color.clear)
    }
}

extension View {
    @MainActor
    func renderAsImage() -> UIImage? {
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.all))
        guard let view = controller.view else { return nil }
        
        let targetSize = controller.view.intrinsicContentSize
        if targetSize == .zero {
            view.bounds = CGRect(origin: .zero, size: CGSize(width: 400, height: 700))
        } else {
            view.bounds = CGRect(origin: .zero, size: targetSize)
        }
        
        view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
