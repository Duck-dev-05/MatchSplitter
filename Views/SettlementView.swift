import SwiftUI

struct SettlementView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSettlement: Settlement?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                let settlements = viewModel.calculateSettlements(for: group)
                
                if settlements.isEmpty {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("Everyone is settled up!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top, 10)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(settlements) { settlement in
                                Button(action: {
                                    selectedSettlement = settlement
                                }) {
                                    SettlementCardView(settlement: settlement)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Settlements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .sheet(item: $selectedSettlement) { settlement in
                QRCodePaymentView(settlement: settlement)
            }
        }
    }
}

struct SettlementCardView: View {
    var settlement: Settlement
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(settlement.fromUser.name)
                    .font(.headline)
                Text("owes \(settlement.toUser.name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "$%.2f", settlement.amount))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Image(systemName: "qrcode")
                .foregroundColor(.indigo)
                .padding(.leading, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct QRCodePaymentView: View {
    var settlement: Settlement
    let generator = QRCodeGenerator()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Pay \(settlement.toUser.name)")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(String(format: "$%.2f", settlement.amount))
                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                    .foregroundColor(.indigo)
                
                let payload = generator.generatePaymentPayload(
                    paymentID: settlement.toUser.paymentID ?? "Unknown",
                    amount: settlement.amount
                )
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
                        .frame(width: 280, height: 280)
                    
                    Image(uiImage: generator.generateQRCode(from: payload))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                }
                
                if let pid = settlement.toUser.paymentID {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.secondary)
                        Text("Payment ID: \(pid)")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
