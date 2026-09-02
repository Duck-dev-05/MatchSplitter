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
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        SummaryCard(title: "Total Revenue", amount: totalRevenue, icon: "dollarsign.circle.fill", color: .green)
                        SummaryCard(title: "Outstanding", amount: outstandingAmount, icon: "exclamationmark.circle.fill", color: .orange)
                        SummaryCard(title: "Pending Invoices", amount: Double(pendingInvoicesCount), icon: "doc.text.fill", color: .blue)
                        SummaryCard(title: "This Month", amount: thisMonthRevenue, icon: "calendar.circle.fill", color: .purple)
                    }
                    .padding(.horizontal)
                    
                    // Recent Invoices
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Invoices")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if recentInvoices.isEmpty {
                            Text("No invoices yet")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            ForEach(recentInvoices.prefix(5)) { invoice in
                                InvoiceRowView(invoice: invoice)
                            }
                        }
                    }
                    
                    // Recent Payments
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Payments")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if recentPayments.isEmpty {
                            Text("No payments yet")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            ForEach(recentPayments.prefix(5)) { payment in
                                PaymentRowView(payment: payment)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
        }
    }
    
    var totalRevenue: Double {
        payments.reduce(0.0) { $0 + $1.amount }
    }
    
    var outstandingAmount: Double {
        invoices.filter { !$0.isPaid }.reduce(0.0) { $0 + $1.remainingAmount }
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
        Array(invoices).sorted { $0.createdAt! > $1.createdAt! }
    }
    
    var recentPayments: [Payment] {
        Array(payments).sorted { $0.paymentDate! > $1.paymentDate! }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(amount.formatted(.currency(code: "USD")))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct InvoiceRowView: View {
    let invoice: Invoice
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(invoice.invoiceNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(invoice.client?.name ?? "No Client")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(invoice.total.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(invoice.status)
                    .font(.caption)
                    .foregroundColor(statusColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    var statusColor: Color {
        switch invoice.statusEnum {
        case .paid: return .green
        case .partial: return .orange
        case .overdue: return .red
        case .sent, .viewed: return .blue
        default: return .gray
        }
    }
}

struct PaymentRowView: View {
    let payment: Payment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(payment.invoice?.invoiceNumber ?? "Unknown Invoice")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(payment.paymentMethod)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(payment.amount.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(payment.paymentDate!.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}