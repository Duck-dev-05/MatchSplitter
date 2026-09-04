import SwiftUI
import CoreData

struct ReportsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var invoices: FetchedResults<Invoice>
    @FetchRequest private var payments: FetchedResults<Payment>
    @FetchRequest private var clients: FetchedResults<Client>
    @FetchRequest private var invoiceItems: FetchedResults<InvoiceItem>
    
    let groupID: UUID
    @State private var csvURL: URL?
    @State private var showShareSheet = false
    
    init(groupID: UUID) {
        self.groupID = groupID
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
            .navigationTitle("Activity")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let url = CSVExporter.exportAllData(context: viewContext, groupID: groupID) {
                            self.csvURL = url
                            self.showShareSheet = true
                        }
                    }) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = csvURL {
                    ShareSheet(activityItems: [url])
                }
            }
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
        case revenue = "Collected"
        case outstanding = "Owed to You"
        case clients = "Players"
        case items = "Expenses"
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
                SummaryCard(title: "Total Collected", amount: totalRevenue, icon: "chart.line.uptrend.xyaxis", isPrimary: true)
                SummaryCard(title: "Avg Collection", amount: averagePayment, icon: "chart.bar.fill", color: .blue)
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
                    VStack(spacing: 0) {
                        let sortedMethods = paymentMethods.sorted(by: { $0.value > $1.value })
                        ForEach(Array(sortedMethods.enumerated()), id: \.offset) { tuple in
                            let index = tuple.offset
                            let (method, amount) = tuple.element
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
                            
                            if index < sortedMethods.count - 1 {
                                Divider().padding(.leading, Theme.spacingM)
                            }
                        }
                    }
                    .cardStyle()
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
                SummaryCard(title: "Pending Splits", amount: Double(filteredInvoices.count), icon: "doc.text.fill", color: .blue, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Outstanding Splits List
            VStack(alignment: .leading, spacing: Theme.spacingM) {
                Text("Outstanding Splits")
                    .font(Typography.subheadline())
                    .padding(.horizontal)
                
                if filteredInvoices.isEmpty {
                    Text("No outstanding splits")
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 0) {
                        let sortedInvoices = filteredInvoices.sorted { $0.dueDate < $1.dueDate }
                        ForEach(Array(sortedInvoices.enumerated()), id: \.element.id) { tuple in
                            let index = tuple.offset
                            let invoice = tuple.element
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
                            
                            if index < sortedInvoices.count - 1 {
                                Divider().padding(.leading, Theme.spacingM)
                            }
                        }
                    }
                    .cardStyle()
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
                SummaryCard(title: "Total Players", amount: Double(clients.count), icon: "person.2.fill", color: .blue, isCurrency: false)
                SummaryCard(title: "Total Splits", amount: Double(invoices.count), icon: "sportscourt", color: Theme.success, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Player List
            VStack(alignment: .leading, spacing: Theme.spacingM) {
                Text("All Players")
                    .font(Typography.subheadline())
                    .padding(.horizontal)
                
                if clients.isEmpty {
                    Text("No players yet")
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 0) {
                        let sortedClients = clients.sorted { $0.name < $1.name }
                        ForEach(Array(sortedClients.enumerated()), id: \.element.id) { tuple in
                            let index = tuple.offset
                            let client = tuple.element
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
                            
                            if index < sortedClients.count - 1 {
                                Divider().padding(.leading, Theme.spacingM)
                            }
                        }
                    }
                    .cardStyle()
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
                SummaryCard(title: "Total Expenses Logged", amount: allItems.reduce(0.0) { $0 + $1.quantity }, icon: "cube.fill", color: Theme.secondary, isCurrency: false)
                SummaryCard(title: "Unique Expenses", amount: Double(itemSales.count), icon: "list.bullet", color: .blue, isCurrency: false)
            }
            .padding(.horizontal)
            
            // Top Expenses
            VStack(alignment: .leading, spacing: Theme.spacingM) {
                Text("Top Expenses")
                    .font(Typography.subheadline())
                    .padding(.horizontal)
                
                if itemSales.isEmpty {
                    Text("No expense data")
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 0) {
                        let sortedItems = Array(itemSales.sorted(by: { $0.value.total > $1.value.total }).prefix(10))
                        ForEach(Array(sortedItems.enumerated()), id: \.offset) { tuple in
                            let index = tuple.offset
                            let (itemName, data) = tuple.element
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
                            
                            if index < sortedItems.count - 1 {
                                Divider().padding(.leading, Theme.spacingM)
                            }
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal)
                }
            }
        }
    }
}