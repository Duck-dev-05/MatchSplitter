import SwiftUI
import CoreData

struct ReportsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var invoices: FetchedResults<Invoice>
    @FetchRequest(sortDescriptors: []) private var payments: FetchedResults<Payment>
    @FetchRequest(sortDescriptors: []) private var clients: FetchedResults<Client>
    @FetchRequest(sortDescriptors: []) private var invoiceItems: FetchedResults<InvoiceItem>
    
    @State private var selectedPeriod: ReportPeriod = .thisMonth
    @State private var selectedReportType: ReportType = .revenue
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(ReportPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Report Type Selector
                    Picker("Report Type", selection: $selectedReportType) {
                        ForEach(ReportType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Report Content
                    switch selectedReportType {
                    case .revenue:
                        RevenueReportView(period: selectedPeriod, invoices: Array(invoices), payments: Array(payments))
                    case .outstanding:
                        OutstandingReportView(period: selectedPeriod, invoices: Array(invoices), payments: Array(payments), clients: Array(clients))
                    case .clients:
                        ClientsReportView(clients: Array(clients), invoices: Array(invoices))
                    case .items:
                        ItemsReportView(invoices: Array(invoices), invoiceItems: Array(invoiceItems))
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Reports")
        }
    }
    
    enum ReportPeriod: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case thisQuarter = "This Quarter"
        case thisYear = "This Year"
        case allTime = "All Time"
    }
    
    enum ReportType: String, CaseIterable {
        case revenue = "Revenue"
        case outstanding = "Outstanding"
        case clients = "Clients"
        case items = "Items"
    }
}

struct RevenueReportView: View {
    let period: ReportsView.ReportPeriod
    let invoices: [Invoice]
    let payments: [Payment]
    
    var filteredPayments: [Payment] {
        let calendar = Calendar.current
        let now = Date()
        
        return payments.filter { payment in
            switch period {
            case .thisWeek:
                return calendar.isDate(payment.paymentDate, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth:
                return calendar.isDate(payment.paymentDate, equalTo: now, toGranularity: .month)
            case .thisQuarter:
                return calendar.isDate(payment.paymentDate, equalTo: now, toGranularity: .quarter)
            case .thisYear:
                return calendar.isDate(payment.paymentDate, equalTo: now, toGranularity: .year)
            case .allTime:
                return true
            }
        }
    }
    
    var totalRevenue: Double {
        filteredPayments.reduce(0.0) { $0 + $1.amount }
    }
    
    var averagePayment: Double {
        filteredPayments.isEmpty ? 0.0 : totalRevenue / Double(filteredPayments.count)
    }
    
    var paymentMethods: [String: Double] {
        var methods: [String: Double] = [:]
        for payment in filteredPayments {
            methods[payment.paymentMethod, default: 0.0] += payment.amount
        }
        return methods
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Summary Cards
            VStack(spacing: 12) {
                SummaryCard(title: "Total Revenue", amount: totalRevenue, icon: "dollarsign.circle.fill", color: .green)
                SummaryCard(title: "Average Payment", amount: averagePayment, icon: "chart.bar.fill", color: .blue)
                SummaryCard(title: "Payment Count", amount: Double(filteredPayments.count), icon: "number.circle.fill", color: .purple)
            }
            .padding(.horizontal)
            
            // Payment Methods Breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("Payment Methods")
                    .font(.headline)
                    .padding(.horizontal)
                
                if paymentMethods.isEmpty {
                    Text("No payment data")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    ForEach(paymentMethods.sorted(by: { $0.value > $1.value }), id: \.key) { method, amount in
                        HStack {
                            Text(method)
                                .font(.subheadline)
                            Spacer()
                            Text(amount.formatted(.currency(code: "USD")))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            let percentage = totalRevenue > 0 ? (amount / totalRevenue) * 100 : 0
                            Text(String(format: "%.1f%%", percentage))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct OutstandingReportView: View {
    let period: ReportsView.ReportPeriod
    let invoices: [Invoice]
    let payments: [Payment]
    let clients: [Client]
    
    func remainingAmount(for invoice: Invoice) -> Double {
        let invoicePayments = payments.filter { $0.invoiceID == invoice.id }
        let paidAmount = invoicePayments.reduce(0.0) { $0 + $1.amount }
        return invoice.total - paidAmount
    }
    
    func clientName(for invoice: Invoice) -> String {
        return clients.first(where: { $0.id == invoice.clientID })?.name ?? "No Client"
    }
    
    var filteredInvoices: [Invoice] {
        let calendar = Calendar.current
        let now = Date()
        
        return invoices.filter { invoice in
            if invoice.isPaid { return false }
            
            switch period {
            case .thisWeek:
                return calendar.isDate(invoice.dueDate, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth:
                return calendar.isDate(invoice.dueDate, equalTo: now, toGranularity: .month)
            case .thisQuarter:
                return calendar.isDate(invoice.dueDate, equalTo: now, toGranularity: .quarter)
            case .thisYear:
                return calendar.isDate(invoice.dueDate, equalTo: now, toGranularity: .year)
            case .allTime:
                return true
            }
        }
    }
    
    var totalOutstanding: Double {
        filteredInvoices.reduce(0.0) { $0 + remainingAmount(for: $1) }
    }
    
    var overdueAmount: Double {
        filteredInvoices.filter { $0.isOverdue }.reduce(0.0) { $0 + remainingAmount(for: $1) }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Summary Cards
            VStack(spacing: 12) {
                SummaryCard(title: "Total Outstanding", amount: totalOutstanding, icon: "exclamationmark.circle.fill", color: .orange)
                SummaryCard(title: "Overdue", amount: overdueAmount, icon: "xmark.circle.fill", color: .red)
                SummaryCard(title: "Pending Invoices", amount: Double(filteredInvoices.count), icon: "doc.text.fill", color: .blue)
            }
            .padding(.horizontal)
            
            // Outstanding Invoices List
            VStack(alignment: .leading, spacing: 12) {
                Text("Outstanding Invoices")
                    .font(.headline)
                    .padding(.horizontal)
                
                if filteredInvoices.isEmpty {
                    Text("No outstanding invoices")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    ForEach(filteredInvoices.sorted { $0.dueDate < $1.dueDate }) { invoice in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(invoice.invoiceNumber)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(clientName(for: invoice))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(remainingAmount(for: invoice).formatted(.currency(code: "USD")))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(invoice.isOverdue ? .red : .secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct ClientsReportView: View {
    let clients: [Client]
    let invoices: [Invoice]
    
    var body: some View {
        VStack(spacing: 16) {
            // Summary
            VStack(spacing: 12) {
                SummaryCard(title: "Total Clients", amount: Double(clients.count), icon: "person.2.fill", color: .blue)
                SummaryCard(title: "Total Invoices", amount: Double(invoices.count), icon: "doc.text.fill", color: .green)
            }
            .padding(.horizontal)
            
            // Client List
            VStack(alignment: .leading, spacing: 12) {
                Text("All Clients")
                    .font(.headline)
                    .padding(.horizontal)
                
                if clients.isEmpty {
                    Text("No clients yet")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    ForEach(clients.sorted { $0.name < $1.name }) { client in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(client.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                if !client.email.isEmpty {
                                    Text(client.email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct ItemsReportView: View {
    let invoices: [Invoice]
    let invoiceItems: [InvoiceItem]
    
    var allItems: [InvoiceItem] {
        var items: [InvoiceItem] = []
        for invoice in invoices {
            let itemsForInvoice = invoiceItems.filter { $0.invoiceID == invoice.id }
            items.append(contentsOf: itemsForInvoice)
        }
        return items
    }
    
    var itemSales: [String: (quantity: Double, total: Double)] {
        var sales: [String: (quantity: Double, total: Double)] = [:]
        for item in allItems {
            if let existing = sales[item.itemDescription] {
                sales[item.itemDescription] = (existing.quantity + item.quantity, existing.total + item.finalTotal)
            } else {
                sales[item.itemDescription] = (item.quantity, item.finalTotal)
            }
        }
        return sales
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Summary
            VStack(spacing: 12) {
                SummaryCard(title: "Total Items Sold", amount: allItems.reduce(0.0) { $0 + $1.quantity }, icon: "cube.fill", color: .purple)
                SummaryCard(title: "Unique Items", amount: Double(itemSales.count), icon: "list.bullet", color: .blue)
            }
            .padding(.horizontal)
            
            // Top Items
            VStack(alignment: .leading, spacing: 12) {
                Text("Top Selling Items")
                    .font(.headline)
                    .padding(.horizontal)
                
                if itemSales.isEmpty {
                    Text("No item data")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    ForEach(itemSales.sorted(by: { $0.value.total > $1.value.total }).prefix(10), id: \.key) { itemName, data in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(itemName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Qty: \(data.quantity, specifier: "%.0f")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(data.total.formatted(.currency(code: "USD")))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}