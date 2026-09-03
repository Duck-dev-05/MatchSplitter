import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.createdAt, ascending: false)],
        animation: .default)
    private var invoices: FetchedResults<Invoice>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Payment.paymentDate, ascending: false)],
        animation: .default)
    private var payments: FetchedResults<Payment>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
        animation: .default)
    private var clients: FetchedResults<Client>
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Summary Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            SummaryCard(title: "Total Revenue", amount: totalRevenue, icon: "chart.line.uptrend.xyaxis", isPrimary: true)
                            SummaryCard(title: "Outstanding", amount: outstandingAmount, icon: "exclamationmark.triangle.fill", color: .orange)
                            SummaryCard(title: "Pending Invoices", amount: Double(pendingInvoicesCount), icon: "doc.text.fill", color: .blue, isCurrency: false)
                            SummaryCard(title: "This Month", amount: thisMonthRevenue, icon: "calendar.badge.clock", color: .purple)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Recent Invoices
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Invoices")
                                .font(.system(.title3, design: .rounded).bold())
                                .padding(.horizontal)
                            
                            if recentInvoices.isEmpty {
                                emptyStateView(message: "No invoices yet", icon: "doc.text.magnifyingglass")
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(recentInvoices.prefix(5)) { invoice in
                                        InvoiceRowView(invoice: invoice, clients: clients)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Recent Payments
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Payments")
                                .font(.system(.title3, design: .rounded).bold())
                                .padding(.horizontal)
                            
                            if recentPayments.isEmpty {
                                emptyStateView(message: "No payments yet", icon: "creditcard.trianglebadge.exclamationmark")
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(recentPayments.prefix(5)) { payment in
                                        PaymentRowView(payment: payment, invoices: invoices)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Dashboard")
        }
    }
    
    private func emptyStateView(message: String, icon: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.5))
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .cardStyle()
        .padding(.horizontal)
    }
    
    var totalRevenue: Double {
        payments.reduce(0.0) { $0 + $1.amount }
    }
    
    var outstandingAmount: Double {
        invoices.filter { !$0.isPaid }.reduce(0.0) { result, invoice in
            let invoicePayments = payments.filter { $0.invoiceID == invoice.id }
            let paidAmount = invoicePayments.reduce(0.0) { $0 + $1.amount }
            let remaining = invoice.total - paidAmount
            return result + remaining
        }
    }
    
    var pendingInvoicesCount: Int {
        invoices.filter { invoice in
            let status = invoice.statusEnum
            return status == .sent || status == .viewed || status == .partial
        }.count
    }
    
    var thisMonthRevenue: Double {
        let calendar = Calendar.current
        let now = Date()
        return payments.filter { payment in
            calendar.isDate(payment.paymentDate, equalTo: now, toGranularity: .month)
        }.reduce(0.0) { $0 + $1.amount }
    }
    
    var recentInvoices: [Invoice] {
        Array(invoices).sorted { $0.createdAt > $1.createdAt }
    }
    
    var recentPayments: [Payment] {
        Array(payments).sorted { $0.paymentDate > $1.paymentDate }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    var color: Color = Theme.primary
    var isCurrency: Bool = true
    var isPrimary: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isPrimary ? .white : color)
                    .padding(8)
                    .background(
                        Circle().fill(isPrimary ? Color.white.opacity(0.2) : color.opacity(0.15))
                    )
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(isPrimary ? .white.opacity(0.8) : .secondary)
                
                Group {
                    if isCurrency {
                        Text(amount.formatted(.currency(code: "USD")))
                    } else {
                        Text("\(Int(amount))")
                    }
                }
                .font(.system(.title3, design: .rounded).bold())
                .foregroundColor(isPrimary ? .white : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
        }
        .padding(16)
        .background(
            Group {
                if isPrimary {
                    Theme.gradientPrimary
                } else {
                    Theme.cardBackground
                }
            }
        )
        .cornerRadius(20)
        .shadow(color: isPrimary ? Theme.primary.opacity(0.3) : Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct InvoiceRowView: View {
    let invoice: Invoice
    let clients: FetchedResults<Client>
    
    var clientName: String {
        clients.first(where: { $0.id == invoice.clientID })?.name ?? "No Client"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(invoice.invoiceNumber)
                    .font(.system(.subheadline, design: .rounded).bold())
                Text(clientName)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(invoice.total.formatted(.currency(code: "USD")))
                    .font(.system(.subheadline, design: .rounded).bold())
                
                Text(invoice.status)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .cardStyle()
    }
    
    var statusColor: Color {
        switch invoice.statusEnum {
        case .paid: return .green
        case .partial: return .orange
        case .overdue: return .red
        case .sent, .viewed: return Theme.primary
        default: return .gray
        }
    }
}

struct PaymentRowView: View {
    let payment: Payment
    let invoices: FetchedResults<Invoice>
    
    var invoiceNumber: String {
        invoices.first(where: { $0.id == payment.invoiceID })?.invoiceNumber ?? "Unknown Invoice"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(invoiceNumber)
                    .font(.system(.subheadline, design: .rounded).bold())
                Text(payment.paymentMethod)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(payment.amount.formatted(.currency(code: "USD")))
                    .font(.system(.subheadline, design: .rounded).bold())
                    .foregroundColor(.green)
                Text(payment.paymentDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .cardStyle()
    }
}