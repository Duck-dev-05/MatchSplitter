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
                Theme.dynamicBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacingL) {
                        // Selectors
                        VStack(spacing: Theme.spacingM) {
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
                        .padding(Theme.spacingM)
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
                        
                        Spacer(minLength: Theme.spacingXL)
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
        VStack(spacing: Theme.spacingL) {
            // Summary Cards
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Theme.spacingM),
                GridItem(.flexible(), spacing: Theme.spacingM)
            ], spacing: Theme.spacingM) {
                SummaryCard(title: "Total Revenue", amount: totalRevenue, icon: "chart.line.uptrend.xyaxis", isPrimary: true)
                SummaryCard(title: "Avg Payment", amount: averagePayment, icon: "chart.bar.fill", color: .blue)
            }
            .padding(.horizontal)
            
            VStack(spacing: Theme.spacingM) {
                SummaryCard(title: "Payment Count", amount: Double(filteredPayments.count), icon: "number.circle.fill", color: Theme.secondary, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Payment Methods Breakdown
            VStack(alignment: .leading, spacing: Theme.spacingM) {
                Text("Payment Methods")
                    .font(Typography.subheadline())
                    .padding(.horizontal)
                
                if paymentMethods.isEmpty {
                    Text("No payment data")
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: Theme.spacingM) {
                        ForEach(paymentMethods.sorted(by: { $0.value > $1.value }), id: \.key) { method, amount in
                            HStack {
                                Text(method)
                                    .font(Typography.bodyBold())
                                Spacer()
                                VStack(alignment: .trailing, spacing: Theme.spacingXS) {
                                    Text(amount.formatted(.currency(code: "VND")))
                                        .font(Typography.bodyBold())
                                        .foregroundColor(Theme.primary)
                                    
                                    let percentage = totalRevenue > 0 ? (amount / totalRevenue) * 100 : 0
                                    Text(String(format: "%.1f%%", percentage))
                                        .font(Typography.caption())
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }
                            }
                            .padding(Theme.spacingM)
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
        VStack(spacing: Theme.spacingL) {
            // Summary Cards
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Theme.spacingM),
                GridItem(.flexible(), spacing: Theme.spacingM)
            ], spacing: Theme.spacingM) {
                SummaryCard(title: "Outstanding", amount: totalOutstanding, icon: "exclamationmark.triangle.fill", color: Theme.warning)
                SummaryCard(title: "Overdue", amount: overdueAmount, icon: "xmark.circle.fill", color: Theme.error)
            }
            .padding(.horizontal)
            
            VStack(spacing: Theme.spacingM) {
                SummaryCard(title: "Pending Invoices", amount: Double(filteredInvoices.count), icon: "doc.text.fill", color: .blue, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Outstanding Invoices List
            VStack(alignment: .leading, spacing: Theme.spacingM) {
                Text("Outstanding Invoices")
                    .font(Typography.subheadline())
                    .padding(.horizontal)
                
                if filteredInvoices.isEmpty {
                    Text("No outstanding invoices")
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: Theme.spacingM) {
                        ForEach(filteredInvoices.sorted { $0.dueDate < $1.dueDate }) { invoice in
                            HStack {
                                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                    Text(invoice.invoiceNumber)
                                        .font(Typography.bodyBold())
                                    Text(clientName(for: invoice))
                                        .font(Typography.caption())
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: Theme.spacingXS) {
                                    Text(remainingAmount(for: invoice).formatted(.currency(code: "VND")))
                                        .font(Typography.bodyBold())
                                    Text(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(Typography.caption())
                                        .foregroundColor(invoice.isOverdue ? Theme.error : Theme.dynamicTextSecondary)
                                }
                            }
                            .padding(Theme.spacingM)
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
        VStack(spacing: Theme.spacingL) {
            // Summary
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Theme.spacingM),
                GridItem(.flexible(), spacing: Theme.spacingM)
            ], spacing: Theme.spacingM) {
                SummaryCard(title: "Total Clients", amount: Double(clients.count), icon: "person.2.fill", color: .blue, isCurrency: false)
                SummaryCard(title: "Total Invoices", amount: Double(invoices.count), icon: "doc.text.fill", color: Theme.success, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Client List
            VStack(alignment: .leading, spacing: Theme.spacingM) {
                Text("All Clients")
                    .font(Typography.subheadline())
                    .padding(.horizontal)
                
                if clients.isEmpty {
                    Text("No clients yet")
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: Theme.spacingM) {
                        ForEach(clients.sorted { $0.name < $1.name }) { client in
                            HStack {
                                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                    Text(client.name)
                                        .font(Typography.bodyBold())
                                    if !client.email.isEmpty {
                                        Text(client.email)
                                            .font(Typography.caption())
                                            .foregroundColor(Theme.dynamicTextSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Theme.dynamicTextSecondary.opacity(0.5))
                                    .font(.caption.bold())
                            }
                            .padding(Theme.spacingM)
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
        VStack(spacing: Theme.spacingL) {
            // Summary
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Theme.spacingM),
                GridItem(.flexible(), spacing: Theme.spacingM)
            ], spacing: Theme.spacingM) {
                SummaryCard(title: "Total Items Sold", amount: allItems.reduce(0.0) { $0 + $1.quantity }, icon: "cube.fill", color: Theme.secondary, isCurrency: false)
                SummaryCard(title: "Unique Items", amount: Double(itemSales.count), icon: "list.bullet", color: .blue, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Top Items
            VStack(alignment: .leading, spacing: Theme.spacingM) {
                Text("Top Selling Items")
                    .font(Typography.subheadline())
                    .padding(.horizontal)
                
                if itemSales.isEmpty {
                    Text("No item data")
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: Theme.spacingM) {
                        ForEach(itemSales.sorted(by: { $0.value.total > $1.value.total }).prefix(10), id: \.key) { itemName, data in
                            HStack {
                                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                    Text(itemName)
                                        .font(Typography.bodyBold())
                                    Text("Qty: \(data.quantity, specifier: "%.0f")")
                                        .font(Typography.caption())
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text(data.total.formatted(.currency(code: "VND")))
                                        .font(Typography.bodyBold())
                                        .foregroundColor(Theme.primary)
                                }
                            }
                            .padding(Theme.spacingM)
                            .cardStyle()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}