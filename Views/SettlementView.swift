import SwiftUI

struct SettlementView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSettlement: Settlement?
    
    var body: some View {
        NavigationView {
            List {
                let settlements = viewModel.calculateSettlements(for: group)
                
                if settlements.isEmpty {
                    Text("Everyone is settled up!")
                } else {
                    ForEach(settlements) { settlement in
                        Button(action: {
                            selectedSettlement = settlement
                        }) {
                            HStack {
                                Text("\(settlement.fromUser.name) owes \(settlement.toUser.name)")
                                Spacer()
                                Text(String(format: "$%.2f", settlement.amount))
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Settlements")
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

struct QRCodePaymentView: View {
    var settlement: Settlement
    let generator = QRCodeGenerator()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Pay \(settlement.toUser.name)")
                .font(.title)
                .bold()
            
            Text(String(format: "$%.2f", settlement.amount))
                .font(.largeTitle)
            
            let payload = generator.generatePaymentPayload(
                paymentID: settlement.toUser.paymentID ?? "Unknown",
                amount: settlement.amount
            )
            
            Image(uiImage: generator.generateQRCode(from: payload))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            
            if let pid = settlement.toUser.paymentID {
                Text("ID: \(pid)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Text("Scan this QR with your payment app to settle the debt.")
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}
