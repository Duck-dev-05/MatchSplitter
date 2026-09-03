import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage private var hasSeenClientOnboarding: Bool
    @State private var showingClientOnboarding = false
    
    @FetchRequest private var invoices: FetchedResults<Invoice>
    @FetchRequest private var payments: FetchedResults<Payment>
    @FetchRequest private var clients: FetchedResults<Client>
    
    let groupID: UUID
    
    init(groupID: UUID) {
        self.groupID = groupID
        let predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        
        _invoices = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.createdAt, ascending: false)],
            predicate: predicate,
            animation: .default)
            
        _payments = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Payment.paymentDate, ascending: false)],
            predicate: predicate,
            animation: .default)
            
        _clients = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
            predicate: predicate,
            animation: .default)
            
        self._hasSeenClientOnboarding = AppStorage(wrappedValue: false, "hasSeenClientOnboarding_\(groupID.uuidString)")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.spacingL) {
                        // Summary Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: Theme.spacingM),
                            GridItem(.flexible(), spacing: Theme.spacingM)
                        ], spacing: Theme.spacingM) {
                            SummaryCard(title: "Total Revenue", amount: totalRevenue, icon: "chart.line.uptrend.xyaxis", isPrimary: true)
                            SummaryCard(title: "Outstanding", amount: outstandingAmount, icon: "exclamationmark.triangle.fill", color: Theme.warning)
                            SummaryCard(title: "Pending Invoices", amount: Double(pendingInvoicesCount), icon: "doc.text.fill", color: .blue, isCurrency: false)
                            SummaryCard(title: "This Month", amount: thisMonthRevenue, icon: "calendar.badge.clock", color: Theme.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, Theme.spacingS)
                        
                        // Recent Invoices
                        VStack(alignment: .leading, spacing: Theme.spacingM) {
                            Text("Recent Invoices")
                                .font(Typography.subheadline())
                                .padding(.horizontal)
                            
                            if recentInvoices.isEmpty {
                                emptyStateView(message: "No invoices yet", icon: "doc.text.magnifyingglass")
                            } else {
                                VStack(spacing: Theme.spacingM) {
                                    ForEach(recentInvoices.prefix(5)) { invoice in
                                        InvoiceRowView(invoice: invoice, clients: clients)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Recent Payments
                        VStack(alignment: .leading, spacing: Theme.spacingM) {
                            Text("Recent Payments")
                                .font(Typography.subheadline())
                                .padding(.horizontal)
                            
                            if recentPayments.isEmpty {
                                emptyStateView(message: "No payments yet", icon: "creditcard.trianglebadge.exclamationmark")
                            } else {
                                VStack(spacing: Theme.spacingM) {
                                    ForEach(recentPayments.prefix(5)) { payment in
                                        PaymentRowView(payment: payment, invoices: invoices)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: Theme.spacingXL)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Dashboard")
        }
        .fullScreenCover(isPresented: $showingClientOnboarding) {
            FirstClientOnboardingView(groupID: groupID, isPresented: $showingClientOnboarding)
                .onDisappear {
                    hasSeenClientOnboarding = true
                }
        }
        .onAppear {
            if clients.isEmpty && !hasSeenClientOnboarding {
                showingClientOnboarding = true
            }
        }
    }
    
    private func emptyStateView(message: String, icon: String) -> some View {
        VStack(spacing: Theme.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(Theme.dynamicTextSecondary.opacity(0.5))
            Text(message)
                .font(Typography.body())
                .foregroundColor(Theme.dynamicTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXL)
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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isPrimary ? .white : color)
                    .padding(Theme.spacingS)
                    .background(
                        Circle().fill(isPrimary ? Color.white.opacity(0.2) : color.opacity(0.15))
                    )
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(title)
                    .font(Typography.caption())
                    .fontWeight(.medium)
                    .foregroundColor(isPrimary ? .white.opacity(0.8) : Theme.dynamicTextSecondary)
                
                Group {
                    if isCurrency {
                        Text(amount.formatted(.currency(code: "VND")))
                    } else {
                        Text("\(Int(amount))")
                    }
                }
                .font(.system(.title3, design: .rounded).bold())
                .foregroundColor(isPrimary ? .white : Theme.dynamicTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
        }
        .padding(Theme.spacingM)
        .background(
            Group {
                if isPrimary {
                    Theme.gradientPrimary
                } else {
                    Theme.dynamicCardBackground
                }
            }
        )
        .cornerRadius(Theme.radiusXL)
        .shadow(color: isPrimary ? Theme.primary.opacity(0.3) : Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 10, x: 0, y: 5)
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
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(invoice.invoiceNumber)
                    .font(Typography.bodyBold())
                Text(clientName)
                    .font(Typography.caption())
                    .foregroundColor(Theme.dynamicTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Theme.spacingXS) {
                Text(invoice.total.formatted(.currency(code: "VND")))
                    .font(Typography.bodyBold())
                
                Text(invoice.status)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, Theme.spacingS)
                    .padding(.vertical, Theme.spacingXS)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(Theme.spacingM)
        .cardStyle()
    }
    
    var statusColor: Color {
        switch invoice.statusEnum {
        case .paid: return Theme.success
        case .partial: return Theme.warning
        case .overdue: return Theme.error
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
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(invoiceNumber)
                    .font(Typography.bodyBold())
                Text(payment.paymentMethod)
                    .font(Typography.caption())
                    .foregroundColor(Theme.dynamicTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Theme.spacingXS) {
                Text(payment.amount.formatted(.currency(code: "VND")))
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.success)
                Text(payment.paymentDate.formatted(date: .abbreviated, time: .omitted))
                    .font(Typography.caption())
                    .foregroundColor(Theme.dynamicTextSecondary)
            }
        }
        .padding(Theme.spacingM)
        .cardStyle()
    }
}

struct FirstClientOnboardingView: View {
    let groupID: UUID
    @Binding var isPresented: Bool
    
    @FetchRequest private var clients: FetchedResults<Client>
    
    @State private var showingAddClient = false
    
    init(groupID: UUID, isPresented: Binding<Bool>) {
        self.groupID = groupID
        self._isPresented = isPresented
        
        let predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        _clients = FetchRequest(
            sortDescriptors: [],
            predicate: predicate,
            animation: .default)
    }
    
    var body: some View {
        ZStack {
            Theme.dynamicBackground.ignoresSafeArea()
            
            VStack(spacing: Theme.spacingXL) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.1))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "person.2.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.primary)
                }
                
                VStack(spacing: Theme.spacingM) {
                    Text("Add Your First Client")
                        .font(.system(.title, design: .rounded).bold())
                    
                    Text("Great job creating your group! Now, let's add a client so you can start generating invoices and tracking revenue.")
                        .font(Typography.body())
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacingXL)
                }
                
                Spacer()
                
                VStack(spacing: Theme.spacingL) {
                    Button {
                        showingAddClient = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Client Now")
                        }
                        .font(Typography.button())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.gradientPrimary)
                        .cornerRadius(Theme.radiusM)
                        .shadow(color: Theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Button {
                        isPresented = false
                    } label: {
                        Text("Skip for now")
                            .font(Typography.button())
                            .foregroundColor(Theme.dynamicTextSecondary)
                    }
                }
                .padding(.horizontal, Theme.spacingXL)
                .padding(.bottom, Theme.spacingXL)
            }
        }
        .sheet(isPresented: $showingAddClient) {
            AddClientView(groupID: groupID)
        }
        .onChange(of: clients.count) { count in
            if count > 0 {
                // If a client was successfully added, auto-dismiss the onboarding
                isPresented = false
            }
        }
    }
}