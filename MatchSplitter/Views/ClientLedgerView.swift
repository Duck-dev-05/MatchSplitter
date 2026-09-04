import SwiftUI
import CoreData

enum LedgerItemType {
    case invoice(Invoice)
    case payment(Payment)
}

struct LedgerItem: Identifiable {
    let id = UUID()
    let date: Date
    let type: LedgerItemType
    let amount: Double
}

struct ClientLedgerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let client: Client
    
    @State private var ledgerItems: [LedgerItem] = []
    
    var body: some View {
        ZStack {
            Theme.dynamicBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Balance
                VStack(spacing: Theme.spacingS) {
                    Text("Running Balance")
                        .font(Typography.subheadline())
                        .foregroundColor(Theme.dynamicTextSecondary)
                    
                    let balance = client.runningBalance(context: viewContext)
                    Text(balance, format: .currency(code: "VND"))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(balance > 0 ? .red : .green)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.dynamicCardBackground)
                
                // Ledger List
                if ledgerItems.isEmpty {
                    Spacer()
                    Text("No transactions yet.")
                        .font(Typography.body())
                        .foregroundColor(Theme.dynamicTextSecondary)
                    Spacer()
                } else {
                    List {
                        ForEach(ledgerItems) { item in
                            LedgerRowView(item: item)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: Theme.spacingXS, leading: Theme.spacingM, bottom: Theme.spacingXS, trailing: Theme.spacingM))
                        }
                    }
                    .listStyle(.plain)
                    .padding(.top, Theme.spacingS)
                }
            }
        }
        .navigationTitle("\(client.name)'s Ledger")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadLedger()
        }
    }
    
    private func loadLedger() {
        // Fetch Invoices
        let invoiceReq: NSFetchRequest<Invoice> = Invoice.fetchRequest()
        invoiceReq.predicate = NSPredicate(format: "clientID == %@ AND status != %@ AND status != %@", client.id as CVarArg, Invoice.InvoiceStatus.void.rawValue, Invoice.InvoiceStatus.draft.rawValue)
        let invoices = (try? viewContext.fetch(invoiceReq)) ?? []
        
        let invoiceIDs = invoices.compactMap { $0.id }
        
        // Fetch Payments
        let paymentReq: NSFetchRequest<Payment> = Payment.fetchRequest()
        paymentReq.predicate = NSPredicate(format: "invoiceID IN %@", invoiceIDs)
        let payments = (try? viewContext.fetch(paymentReq)) ?? []
        
        var items: [LedgerItem] = []
        
        for inv in invoices {
            items.append(LedgerItem(date: inv.issueDate, type: .invoice(inv), amount: inv.total))
        }
        
        for pay in payments {
            items.append(LedgerItem(date: pay.paymentDate, type: .payment(pay), amount: pay.amount))
        }
        
        // Sort ascending by date
        self.ledgerItems = items.sorted { $0.date > $1.date }
    }
}

struct LedgerRowView: View {
    let item: LedgerItem
    
    var body: some View {
        HStack(spacing: Theme.spacingM) {
            Circle()
                .fill(isPayment ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: isPayment ? "arrow.down.left" : "arrow.up.right")
                        .foregroundColor(isPayment ? .green : .red)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Typography.bodyBold())
                Text(item.date, style: .date)
                    .font(Typography.caption())
                    .foregroundColor(Theme.dynamicTextSecondary)
            }
            
            Spacer()
            
            Text(isPayment ? "-\(item.amount.formatted(.currency(code: "VND")))" : "+\(item.amount.formatted(.currency(code: "VND")))")
                .font(Typography.bodyBold())
                .foregroundColor(isPayment ? .green : .red)
        }
        .padding(.vertical, Theme.spacingS)
        .padding(.horizontal, Theme.spacingM)
        .background(Theme.dynamicCardBackground)
        .cornerRadius(Theme.radiusM)
    }
    
    var isPayment: Bool {
        switch item.type {
        case .payment: return true
        case .invoice: return false
        }
    }
    
    var title: String {
        switch item.type {
        case .payment(let pay): return "Payment (\(pay.paymentMethod))"
        case .invoice(let inv): return "Invoice \(inv.invoiceNumber)"
        }
    }
}
