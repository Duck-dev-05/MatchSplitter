import SwiftUI
import CoreData

struct ReportsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var invoices: FetchedResults<Invoice>
    @FetchRequest private var payments: FetchedResults<Payment>
    @FetchRequest private var clients: FetchedResults<Client>
    @FetchRequest private var invoiceItems: FetchedResults<InvoiceItem>
    
    init(groupID: UUID) {
        let predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        
        _invoices = FetchRequest(sortDescriptors: [], predicate: predicate)
        _payments = FetchRequest(sortDescriptors: [], predicate: predicate)
        _clients = FetchRequest(sortDescriptors: [], predicate: predicate)
        // InvoiceItems don't have groupID currently; we'll fetch all and filter in code
        _invoiceItems = FetchRequest(sortDescriptors: [])
    }
    
    @State private var selectedPeriod: ReportPeriod = .thisMonth
    @State private var selectedReportType: ReportType = .revenue
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Selectors
                        VStack(spacing: 16) {
                            Picker("Period", selection: $selectedPeriod) {
                                ForEach(ReportPeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            Picker("Report Type", selection: $selectedReportType) {
                                ForEach(ReportType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(16)
                        .cardStyle()
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
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.vertical)
                }
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
        VStack(spacing: 24) {
            // Summary Cards
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                SummaryCard(title: "Total Revenue", amount: totalRevenue, icon: "chart.line.uptrend.xyaxis", isPrimary: true)
                SummaryCard(title: "Avg Payment", amount: averagePayment, icon: "chart.bar.fill", color: .blue)
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                SummaryCard(title: "Payment Count", amount: Double(filteredPayments.count), icon: "number.circle.fill", color: .purple, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Payment Methods Breakdown
            VStack(alignment: .leading, spacing: 16) {
                Text("Payment Methods")
                    .font(.system(.title3, design: .rounded).bold())
                    .padding(.horizontal)
                
                if paymentMethods.isEmpty {
                    Text("No payment data")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        ForEach(paymentMethods.sorted(by: { $0.value > $1.value }), id: \.key) { method, amount in
                            HStack {
                                Text(method)
                                    .font(.system(.subheadline, design: .rounded).bold())
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(amount.formatted(.currency(code: "USD")))
                                        .font(.system(.subheadline, design: .rounded).bold())
                                        .foregroundColor(Theme.primary)
                                    
                                    let percentage = totalRevenue > 0 ? (amount / totalRevenue) * 100 : 0
                                    Text(String(format: "%.1f%%", percentage))
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(16)
                            .cardStyle()
                        }
                    }
                    .padding(.horizontal)
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
        VStack(spacing: 24) {
            // Summary Cards
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                SummaryCard(title: "Outstanding", amount: totalOutstanding, icon: "exclamationmark.triangle.fill", color: .orange)
                SummaryCard(title: "Overdue", amount: overdueAmount, icon: "xmark.circle.fill", color: .red)
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                SummaryCard(title: "Pending Invoices", amount: Double(filteredInvoices.count), icon: "doc.text.fill", color: .blue, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Outstanding Invoices List
            VStack(alignment: .leading, spacing: 16) {
                Text("Outstanding Invoices")
                    .font(.system(.title3, design: .rounded).bold())
                    .padding(.horizontal)
                
                if filteredInvoices.isEmpty {
                    Text("No outstanding invoices")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredInvoices.sorted { $0.dueDate < $1.dueDate }) { invoice in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(invoice.invoiceNumber)
                                        .font(.system(.subheadline, design: .rounded).bold())
                                    Text(clientName(for: invoice))
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(remainingAmount(for: invoice).formatted(.currency(code: "USD")))
                                        .font(.system(.subheadline, design: .rounded).bold())
                                    Text(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(invoice.isOverdue ? .red : .secondary)
                                }
                            }
                            .padding(16)
                            .cardStyle()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct ClientsReportView: View {
    let clients: [Client]
    let invoices: [Invoice]
    
    var body: some View {
        VStack(spacing: 24) {
            // Summary
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                SummaryCard(title: "Total Clients", amount: Double(clients.count), icon: "person.2.fill", color: .blue, isCurrency: false)
                SummaryCard(title: "Total Invoices", amount: Double(invoices.count), icon: "doc.text.fill", color: .green, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Client List
            VStack(alignment: .leading, spacing: 16) {
                Text("All Clients")
                    .font(.system(.title3, design: .rounded).bold())
                    .padding(.horizontal)
                
                if clients.isEmpty {
                    Text("No clients yet")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        ForEach(clients.sorted { $0.name < $1.name }) { client in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(client.name)
                                        .font(.system(.subheadline, design: .rounded).bold())
                                    if !client.email.isEmpty {
                                        Text(client.email)
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .font(.caption.bold())
                            }
                            .padding(16)
                            .cardStyle()
                        }
                    }
                    .padding(.horizontal)
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
        VStack(spacing: 24) {
            // Summary
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                SummaryCard(title: "Total Items Sold", amount: allItems.reduce(0.0) { $0 + $1.quantity }, icon: "cube.fill", color: .purple, isCurrency: false)
                SummaryCard(title: "Unique Items", amount: Double(itemSales.count), icon: "list.bullet", color: .blue, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Top Items
            VStack(alignment: .leading, spacing: 16) {
                Text("Top Selling Items")
                    .font(.system(.title3, design: .rounded).bold())
                    .padding(.horizontal)
                
                if itemSales.isEmpty {
                    Text("No item data")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        ForEach(itemSales.sorted(by: { $0.value.total > $1.value.total }).prefix(10), id: \.key) { itemName, data in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(itemName)
                                        .font(.system(.subheadline, design: .rounded).bold())
                                    Text("Qty: \(data.quantity, specifier: "%.0f")")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text(data.total.formatted(.currency(code: "USD")))
                                        .font(.system(.subheadline, design: .rounded).bold())
                                        .foregroundColor(Theme.primary)
                                }
                            }
                            .padding(16)
                            .cardStyle()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}