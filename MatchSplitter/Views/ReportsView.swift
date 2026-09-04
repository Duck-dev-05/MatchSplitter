import SwiftUI
import CoreData

// MARK: - ReportsView

struct ReportsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var invoices:     FetchedResults<Invoice>
    @FetchRequest private var payments:     FetchedResults<Payment>
    @FetchRequest private var clients:      FetchedResults<Client>
    @FetchRequest private var invoiceItems: FetchedResults<InvoiceItem>

    let groupID: UUID
    @State private var csvURL:          URL?
    @State private var showShareSheet = false
    @State private var selectedPeriod:     ReportPeriod = .thisMonth
    @State private var selectedReportType: ReportType   = .revenue

    init(groupID: UUID) {
        self.groupID = groupID
        let predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        _invoices     = FetchRequest(sortDescriptors: [], predicate: predicate)
        _payments     = FetchRequest(sortDescriptors: [], predicate: predicate)
        _clients      = FetchRequest(sortDescriptors: [], predicate: predicate)
        _invoiceItems = FetchRequest(sortDescriptors: [])
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.spacingL) {

                        // ── Filter Controls ──
                        VStack(spacing: Theme.spacingM) {
                            // Period chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Theme.spacingS) {
                                    ForEach(ReportPeriod.allCases, id: \.self) { period in
                                        PeriodChip(
                                            title: period.rawValue,
                                            isSelected: selectedPeriod == period
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedPeriod = period
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            // Report type tabs
                            HStack(spacing: 0) {
                                ForEach(ReportType.allCases, id: \.self) { type in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedReportType = type
                                        }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Image(systemName: type.icon)
                                                .font(.system(size: 15, weight: .semibold))
                                            Text(type.rawValue)
                                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .foregroundColor(selectedReportType == type ? Theme.primary : Theme.dynamicTextSecondary)
                                        .background(
                                            selectedReportType == type
                                                ? Theme.primary.opacity(0.10)
                                                : Color.clear
                                        )
                                        .cornerRadius(Theme.radiusM)
                                    }
                                }
                            }
                            .padding(4)
                            .background(Theme.dynamicCardBackground)
                            .cornerRadius(Theme.radiusL)
                            .padding(.horizontal)
                        }
                        .padding(.top, Theme.spacingS)

                        // ── Report Content ──
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

                        Spacer(minLength: Theme.spacingXXL)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Activity")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if let url = CSVExporter.exportAllData(context: viewContext, groupID: groupID) {
                            self.csvURL = url
                            self.showShareSheet = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = csvURL { ShareSheet(activityItems: [url]) }
            }
        }
    }

    // MARK: - Enums

    enum ReportPeriod: String, CaseIterable {
        case thisWeek    = "Week"
        case thisMonth   = "Month"
        case thisQuarter = "Quarter"
        case thisYear    = "Year"
        case allTime     = "All Time"
    }

    enum ReportType: String, CaseIterable {
        case revenue     = "Collected"
        case outstanding = "Owed"
        case clients     = "Players"
        case items       = "Expenses"

        var icon: String {
            switch self {
            case .revenue:     return "chart.bar.fill"
            case .outstanding: return "exclamationmark.circle.fill"
            case .clients:     return "person.2.fill"
            case .items:       return "list.bullet.rectangle"
            }
        }
    }
}

// MARK: - PeriodChip

private struct PeriodChip: View {
    let title:      String
    let isSelected: Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : Theme.dynamicTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.primary : Theme.dynamicCardBackground)
                .cornerRadius(Theme.radiusXL)
                .shadow(
                    color: isSelected ? Theme.primary.opacity(0.3) : Color.clear,
                    radius: 6, x: 0, y: 3
                )
        }
    }
}

// MARK: - Section Header Helper

private func reportSectionHeader(_ title: String) -> some View {
    HStack {
        Text(title)
            .font(Typography.subheadlineBold())
            .foregroundColor(Theme.dynamicTextPrimary)
        Spacer()
    }
    .padding(.horizontal)
}

// MARK: - RevenueReportView

struct RevenueReportView: View {
    let period:   ReportsView.ReportPeriod
    let invoices: [Invoice]
    let payments: [Payment]

    var filteredPayments: [Payment] {
        let calendar = Calendar.current
        let now = Date()
        return payments.filter { p in
            switch period {
            case .thisWeek:    return calendar.isDate(p.paymentDate, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth:   return calendar.isDate(p.paymentDate, equalTo: now, toGranularity: .month)
            case .thisQuarter: return calendar.isDate(p.paymentDate, equalTo: now, toGranularity: .quarter)
            case .thisYear:    return calendar.isDate(p.paymentDate, equalTo: now, toGranularity: .year)
            case .allTime:     return true
            }
        }
    }

    var totalRevenue:    Double { filteredPayments.reduce(0.0) { $0 + $1.amount } }
    var averagePayment:  Double { filteredPayments.isEmpty ? 0 : totalRevenue / Double(filteredPayments.count) }
    var paymentMethods:  [String: Double] {
        filteredPayments.reduce(into: [:]) { $0[$1.paymentMethod, default: 0] += $1.amount }
    }

    var body: some View {
        VStack(spacing: Theme.spacingL) {
            // Hero stat
            statHero(
                label: "Total Collected",
                value: totalRevenue.formatted(.currency(code: "VND")),
                icon: "chart.bar.fill",
                color: Theme.success
            )

            // Mini stat row
            HStack(spacing: Theme.spacingM) {
                miniStat(label: "Avg Collection", value: averagePayment.formatted(.currency(code: "VND")), icon: "chart.bar.fill", color: Theme.primary)
                miniStat(label: "Total Payments", value: "\(filteredPayments.count)", icon: "number.circle.fill", color: Theme.secondary, isCurrency: false)
            }
            .padding(.horizontal)

            // Payment methods
            reportSectionHeader("Payment Methods")

            if paymentMethods.isEmpty {
                activityEmptyState(message: "No payments recorded", icon: "creditcard")
            } else {
                VStack(spacing: Theme.spacingS) {
                    let sorted = paymentMethods.sorted { $0.value > $1.value }
                    ForEach(Array(sorted.enumerated()), id: \.offset) { _, pair in
                        let (method, amount) = pair
                        let pct = totalRevenue > 0 ? (amount / totalRevenue) : 0
                        ActivityRowCard {
                            HStack(spacing: Theme.spacingM) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Theme.radiusS)
                                        .fill(Theme.primary.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "creditcard.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Theme.primary)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(method)
                                        .font(Typography.bodyBold())
                                    // Progress bar
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule().fill(Theme.border.opacity(0.3)).frame(height: 4)
                                            Capsule().fill(Theme.primary).frame(width: geo.size.width * CGFloat(pct), height: 4)
                                        }
                                    }
                                    .frame(height: 4)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(amount.formatted(.currency(code: "VND")))
                                        .font(Typography.bodyBold())
                                        .foregroundColor(Theme.primary)
                                    Text(String(format: "%.1f%%", pct * 100))
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - OutstandingReportView

struct OutstandingReportView: View {
    let period:   ReportsView.ReportPeriod
    let invoices: [Invoice]
    let payments: [Payment]
    let clients:  [Client]

    func remainingAmount(for invoice: Invoice) -> Double {
        let paid = payments.filter { $0.invoiceID == invoice.id }.reduce(0.0) { $0 + $1.amount }
        return invoice.total - paid
    }

    func clientName(for invoice: Invoice) -> String {
        clients.first(where: { $0.id == invoice.clientID })?.name ?? "Unknown"
    }

    var filteredInvoices: [Invoice] {
        let calendar = Calendar.current
        let now = Date()
        return invoices.filter { inv in
            if inv.isPaid { return false }
            switch period {
            case .thisWeek:    return calendar.isDate(inv.dueDate, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth:   return calendar.isDate(inv.dueDate, equalTo: now, toGranularity: .month)
            case .thisQuarter: return calendar.isDate(inv.dueDate, equalTo: now, toGranularity: .quarter)
            case .thisYear:    return calendar.isDate(inv.dueDate, equalTo: now, toGranularity: .year)
            case .allTime:     return true
            }
        }
    }

    var totalOutstanding: Double { filteredInvoices.reduce(0.0) { $0 + remainingAmount(for: $1) } }
    var overdueAmount:    Double { filteredInvoices.filter { $0.isOverdue }.reduce(0.0) { $0 + remainingAmount(for: $1) } }

    var body: some View {
        VStack(spacing: Theme.spacingL) {
            // Hero stat
            statHero(
                label: "Total Outstanding",
                value: totalOutstanding.formatted(.currency(code: "VND")),
                icon: "exclamationmark.triangle.fill",
                color: Theme.warning
            )

            HStack(spacing: Theme.spacingM) {
                miniStat(label: "Overdue", value: overdueAmount.formatted(.currency(code: "VND")), icon: "xmark.circle.fill", color: Theme.error)
                miniStat(label: "Pending Splits", value: "\(filteredInvoices.count)", icon: "doc.text.fill", color: Theme.primary, isCurrency: false)
            }
            .padding(.horizontal)

            reportSectionHeader("Outstanding Splits")

            if filteredInvoices.isEmpty {
                activityEmptyState(message: "All splits settled!", icon: "checkmark.circle.fill")
            } else {
                VStack(spacing: Theme.spacingS) {
                    ForEach(filteredInvoices.sorted { $0.dueDate < $1.dueDate }) { invoice in
                        let isOverdue = invoice.isOverdue
                        ActivityRowCard {
                            HStack(spacing: Theme.spacingM) {
                                // Status dot
                                ZStack {
                                    RoundedRectangle(cornerRadius: Theme.radiusS)
                                        .fill(isOverdue ? Theme.error.opacity(0.12) : Theme.warning.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: isOverdue ? "xmark.circle.fill" : "clock.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(isOverdue ? Theme.error : Theme.warning)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(clientName(for: invoice))
                                        .font(Typography.bodyBold())
                                    Text(invoice.invoiceNumber)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(remainingAmount(for: invoice).formatted(.currency(code: "VND")))
                                        .font(Typography.bodyBold())
                                        .foregroundColor(isOverdue ? Theme.error : Theme.dynamicTextPrimary)

                                    Text(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundColor(isOverdue ? Theme.error : Theme.dynamicTextSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - ClientsReportView

struct ClientsReportView: View {
    let clients:  [Client]
    let invoices: [Invoice]

    var body: some View {
        VStack(spacing: Theme.spacingL) {
            HStack(spacing: Theme.spacingM) {
                miniStat(label: "Total Players", value: "\(clients.count)", icon: "person.2.fill", color: Theme.primary, isCurrency: false)
                miniStat(label: "Total Splits",  value: "\(invoices.count)", icon: "sportscourt.fill", color: Theme.success, isCurrency: false)
            }
            .padding(.horizontal)

            reportSectionHeader("All Players")

            if clients.isEmpty {
                activityEmptyState(message: "No players in this team yet", icon: "person.3")
            } else {
                VStack(spacing: Theme.spacingS) {
                    ForEach(clients.sorted { $0.name < $1.name }) { client in
                        ActivityRowCard {
                            HStack(spacing: Theme.spacingM) {
                                // Gradient avatar
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
                                        .frame(width: 42, height: 42)
                                    Text(String(client.name.prefix(1)).uppercased())
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(client.name)
                                        .font(Typography.bodyBold())
                                    if !client.email.isEmpty {
                                        Text(client.email)
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(Theme.dynamicTextSecondary)
                                    }
                                }

                                Spacer()

                                let splitCount = invoices.filter { $0.clientID == client.id }.count
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(splitCount)")
                                        .font(Typography.bodyBold())
                                        .foregroundColor(Theme.primary)
                                    Text("splits")
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - ItemsReportView

struct ItemsReportView: View {
    let invoices:     [Invoice]
    let invoiceItems: [InvoiceItem]

    var allItems: [InvoiceItem] {
        invoices.flatMap { inv in invoiceItems.filter { $0.invoiceID == inv.id } }
    }

    var itemSales: [String: (quantity: Double, total: Double)] {
        allItems.reduce(into: [:]) { dict, item in
            if let ex = dict[item.itemDescription] {
                dict[item.itemDescription] = (ex.quantity + item.quantity, ex.total + item.finalTotal)
            } else {
                dict[item.itemDescription] = (item.quantity, item.finalTotal)
            }
        }
    }

    var grandTotal: Double { allItems.reduce(0) { $0 + $1.finalTotal } }

    var body: some View {
        VStack(spacing: Theme.spacingL) {
            HStack(spacing: Theme.spacingM) {
                miniStat(label: "Total Expenses", value: grandTotal.formatted(.currency(code: "VND")), icon: "cube.fill", color: Theme.secondary)
                miniStat(label: "Unique Items", value: "\(itemSales.count)", icon: "list.bullet", color: Theme.primary, isCurrency: false)
            }
            .padding(.horizontal)

            reportSectionHeader("Top Expenses")

            if itemSales.isEmpty {
                activityEmptyState(message: "No expense items logged yet", icon: "cube.box")
            } else {
                VStack(spacing: Theme.spacingS) {
                    let sorted = Array(itemSales.sorted { $0.value.total > $1.value.total }.prefix(10))
                    ForEach(Array(sorted.enumerated()), id: \.offset) { index, pair in
                        let (itemName, data) = pair
                        ActivityRowCard {
                            HStack(spacing: Theme.spacingM) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Theme.radiusS)
                                        .fill(Theme.secondary.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .black, design: .rounded))
                                        .foregroundColor(Theme.secondary)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(itemName)
                                        .font(Typography.bodyBold())
                                    Text("Qty: \(data.quantity, specifier: "%.0f")")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }

                                Spacer()

                                Text(data.total.formatted(.currency(code: "VND")))
                                    .font(Typography.bodyBold())
                                    .foregroundColor(Theme.primary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Shared Helper Views

/// A rounded card wrapper for activity list rows
struct ActivityRowCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(.vertical, Theme.spacingS + 2)
            .padding(.horizontal, Theme.spacingM)
            .background(Theme.dynamicCardBackground)
            .cornerRadius(Theme.radiusL)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.05), radius: 6, x: 0, y: 2)
    }
}

/// Hero metric card at the top of each report section
private func statHero(label: String, value: String, icon: String, color: Color) -> some View {
    HStack(spacing: Theme.spacingL) {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 64, height: 64)
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(color)
        }
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.dynamicTextSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(Theme.dynamicTextPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        Spacer()
    }
    .padding(Theme.spacingM)
    .background(
        LinearGradient(
            colors: [color.opacity(0.08), color.opacity(0.03)],
            startPoint: .leading, endPoint: .trailing
        )
    )
    .cornerRadius(Theme.radiusXL)
    .overlay(
        RoundedRectangle(cornerRadius: Theme.radiusXL)
            .stroke(color.opacity(0.15), lineWidth: 1)
    )
    .padding(.horizontal)
}

/// Small two-column stat card
private func miniStat(label: String, value: String, icon: String, color: Color, isCurrency: Bool = true) -> some View {
    HStack(spacing: Theme.spacingS) {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(color)
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Theme.dynamicTextSecondary)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Theme.dynamicTextPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        Spacer()
    }
    .padding(Theme.spacingM)
    .background(Theme.dynamicCardBackground)
    .cornerRadius(Theme.radiusL)
    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
}

/// Centered empty state used within report sections
private func activityEmptyState(message: String, icon: String) -> some View {
    VStack(spacing: Theme.spacingM) {
        Image(systemName: icon)
            .font(.system(size: 36))
            .foregroundColor(Theme.dynamicTextSecondary.opacity(0.35))
        Text(message)
            .font(Typography.caption())
            .foregroundColor(Theme.dynamicTextSecondary)
            .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, Theme.spacingXL)
    .padding(.horizontal)
}