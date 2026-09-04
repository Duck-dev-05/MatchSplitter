import SwiftUI
import CoreData

// MARK: - Data Models

enum LedgerItemType {
    case invoice(Invoice)
    case payment(Payment)
}

struct LedgerItem: Identifiable {
    let id    = UUID()
    let date:   Date
    let type:   LedgerItemType
    let amount: Double
}

// MARK: - ClientLedgerView

struct ClientLedgerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let client: Client

    @State private var ledgerItems: [LedgerItem] = []

    private var runningBalance: Double {
        client.runningBalance(context: viewContext)
    }

    var body: some View {
        ZStack {
            Theme.dynamicBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Balance Header Card ──
                balanceHeader

                // ── Ledger List ──
                if ledgerItems.isEmpty {
                    Spacer()
                    VStack(spacing: Theme.spacingM) {
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundColor(Theme.dynamicTextSecondary.opacity(0.35))
                        Text("No transactions yet.")
                            .font(Typography.caption())
                            .foregroundColor(Theme.dynamicTextSecondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(ledgerItems) { item in
                            LedgerRowView(item: item)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(
                                    top: Theme.spacingXS, leading: Theme.spacingM,
                                    bottom: Theme.spacingXS, trailing: Theme.spacingM
                                ))
                        }
                    }
                    .listStyle(.plain)
                    .padding(.top, Theme.spacingS)
                }
            }
        }
        .navigationTitle("\(client.name)'s Ledger")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadLedger() }
    }

    // MARK: - Balance Header

    private var balanceHeader: some View {
        let isPositive = runningBalance > 0  // still owes money
        return VStack(spacing: Theme.spacingS) {
            // Avatar
            let hue = Double(abs(client.name.hashValue) % 360) / 360.0
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: hue, saturation: 0.65, brightness: 0.85),
                                Color(hue: (hue + 0.08).truncatingRemainder(dividingBy: 1.0), saturation: 0.8, brightness: 0.65)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color(hue: hue, saturation: 0.65, brightness: 0.75).opacity(0.4), radius: 10, x: 0, y: 4)
                Text(String(client.name.prefix(1)).uppercased())
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }

            Text(client.name)
                .font(Typography.headline())

            // Balance pill
            VStack(spacing: 2) {
                Text("Running Balance")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(isPositive ? Theme.error.opacity(0.8) : Theme.success.opacity(0.8))
                    .textCase(.uppercase)
                    .tracking(0.5)
                Text(runningBalance, format: .currency(code: "VND"))
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(isPositive ? Theme.error : Theme.success)
            }
            .padding(.horizontal, Theme.spacingXL)
            .padding(.vertical, Theme.spacingM)
            .background(
                (isPositive ? Theme.error : Theme.success).opacity(0.08)
            )
            .cornerRadius(Theme.radiusXL)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusXL)
                    .stroke((isPositive ? Theme.error : Theme.success).opacity(0.18), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingL)
        .background(Theme.dynamicCardBackground)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    // MARK: - Data

    private func loadLedger() {
        let invoiceReq: NSFetchRequest<Invoice> = Invoice.fetchRequest()
        invoiceReq.predicate = NSPredicate(
            format: "clientID == %@ AND status != %@ AND status != %@",
            client.id as CVarArg,
            Invoice.InvoiceStatus.void.rawValue,
            Invoice.InvoiceStatus.draft.rawValue
        )
        let invoices = (try? viewContext.fetch(invoiceReq)) ?? []
        let invoiceIDs = invoices.compactMap { $0.id }

        let paymentReq: NSFetchRequest<Payment> = Payment.fetchRequest()
        paymentReq.predicate = NSPredicate(format: "invoiceID IN %@", invoiceIDs)
        let payments = (try? viewContext.fetch(paymentReq)) ?? []

        var items: [LedgerItem] = []
        invoices.forEach { items.append(LedgerItem(date: $0.issueDate, type: .invoice($0), amount: $0.total)) }
        payments.forEach  { items.append(LedgerItem(date: $0.paymentDate, type: .payment($0), amount: $0.amount)) }
        self.ledgerItems = items.sorted { $0.date > $1.date }
    }
}

// MARK: - LedgerRowView

struct LedgerRowView: View {
    let item: LedgerItem

    var isPayment: Bool {
        if case .payment = item.type { return true }
        return false
    }

    var title: String {
        switch item.type {
        case .payment(let pay): return "Payment · \(pay.paymentMethod)"
        case .invoice(let inv): return "Split \(inv.invoiceNumber)"
        }
    }

    var accentColor: Color { isPayment ? Theme.success : Theme.error }

    var body: some View {
        HStack(spacing: Theme.spacingM) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: isPayment ? "arrow.down.left" : "arrow.up.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.dynamicTextPrimary)
                Text(item.date, style: .date)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Theme.dynamicTextSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(isPayment
                     ? "-\(item.amount.formatted(.currency(code: "VND")))"
                     : "+\(item.amount.formatted(.currency(code: "VND")))"
                )
                .font(Typography.bodyBold())
                .foregroundColor(accentColor)

                Text(isPayment ? "PAID" : "BILLED")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor.opacity(0.7))
                    .tracking(0.5)
            }
        }
        .padding(.vertical, Theme.spacingS + 2)
        .padding(.horizontal, Theme.spacingM)
        .background(Theme.dynamicCardBackground)
        .cornerRadius(Theme.radiusL)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
