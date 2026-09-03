import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var session: SessionManager
    @AppStorage private var hasSeenClientOnboarding: Bool
    @State private var showingClientOnboarding = false
    @State private var showingPaymentQR = false
    
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
                        // Premium Fintech Balance Display
                        VStack(spacing: Theme.spacingS) {
                            Text("Total Outstanding")
                                .font(Typography.subheadlineBold())
                                .foregroundColor(Theme.dynamicTextSecondary)
                                .textCase(.uppercase)
                            
                            Text(outstandingAmount.formatted(.currency(code: "VND")))
                                .font(Typography.amountLarge())
                                .foregroundColor(outstandingAmount > 0 ? Theme.primary : Theme.dynamicTextPrimary)
                            
                            HStack(spacing: Theme.spacingM) {
                                HStack {
                                    Circle()
                                        .fill(Theme.success)
                                        .frame(width: 8, height: 8)
                                    Text("Collected: \(totalRevenue.formatted(.currency(code: "VND")))")
                                        .font(Typography.caption())
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }
                            }
                            .padding(.top, Theme.spacingXS)
                            
                            // Action Buttons
                            if let bank = session.currentGroup?.bankName, !bank.isEmpty {
                                Button {
                                    showingPaymentQR = true
                                } label: {
                                    HStack {
                                        Image(systemName: "qrcode")
                                        Text("Receive Payment")
                                    }
                                    .font(Typography.button())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.primary)
                                    .cornerRadius(Theme.radiusXL)
                                    .shadow(color: Theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .padding(.top, Theme.spacingM)
                                .padding(.horizontal, Theme.spacingL)
                            }
                        }
                        .padding(.vertical, Theme.spacingXL)
                        .frame(maxWidth: .infinity)
                        .background(Theme.dynamicBackground)
                        
                        // Recent Splits
                        VStack(alignment: .leading, spacing: Theme.spacingM) {
                            Text("Recent Splits")
                                .font(Typography.subheadline())
                                .padding(.horizontal)
                            
                            if recentInvoices.isEmpty {
                                emptyStateView(message: "No matches yet. Add a split!", icon: "sportscourt")
                            } else {
                                VStack(spacing: Theme.spacingM) {
                                    ForEach(recentInvoices.prefix(5)) { invoice in
                                        InvoiceRowView(invoice: invoice, clients: clients)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Recent Activity
                        VStack(alignment: .leading, spacing: Theme.spacingM) {
                            Text("Recent Activity")
                                .font(Typography.subheadline())
                                .padding(.horizontal)
                            
                            if recentPayments.isEmpty {
                                emptyStateView(message: "No payments yet", icon: "clock.arrow.circlepath")
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
            .navigationTitle("Home")
        }
        .fullScreenCover(isPresented: $showingClientOnboarding) {
            FirstClientOnboardingView(groupID: groupID, isPresented: $showingClientOnboarding)
                .onDisappear {
                    hasSeenClientOnboarding = true
                }
        }
        .sheet(isPresented: $showingPaymentQR) {
            if let group = session.currentGroup {
                PaymentQRSheetView(group: group)
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
        clients.first(where: { $0.id == invoice.clientID })?.name ?? "No Player"
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "doc.text.fill")
                    .foregroundColor(Theme.primary)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(clientName)
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.dynamicTextPrimary)
                Text(invoice.invoiceNumber)
                    .font(Typography.caption())
                    .foregroundColor(Theme.dynamicTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Theme.spacingXS) {
                Text(invoice.total.formatted(.currency(code: "VND")))
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.dynamicTextPrimary)
                
                Text(invoice.status)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor)
            }
        }
        .padding(.vertical, Theme.spacingS)
        .padding(.horizontal, Theme.spacingM)
        .background(Theme.dynamicCardBackground)
        .cornerRadius(Theme.radiusM)
    }
    
    var statusColor: Color {
        switch invoice.statusEnum {
        case .paid: return Theme.success
        case .partial: return Theme.warning
        case .overdue: return Theme.error
        case .sent, .viewed: return Theme.primary
        default: return Theme.dynamicTextSecondary
        }
    }
}

struct PaymentRowView: View {
    let payment: Payment
    let invoices: FetchedResults<Invoice>
    
    var invoiceNumber: String {
        invoices.first(where: { $0.id == payment.invoiceID })?.invoiceNumber ?? "Unknown Split"
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Theme.success.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "arrow.down.left")
                    .foregroundColor(Theme.success)
                    .font(.system(size: 20, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(invoiceNumber)
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.dynamicTextPrimary)
                Text(payment.paymentMethod)
                    .font(Typography.caption())
                    .foregroundColor(Theme.dynamicTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Theme.spacingXS) {
                Text("+\(payment.amount.formatted(.currency(code: "VND")))")
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.success)
                Text(payment.paymentDate.formatted(date: .abbreviated, time: .omitted))
                    .font(Typography.caption())
                    .foregroundColor(Theme.dynamicTextSecondary)
            }
        }
        .padding(.vertical, Theme.spacingS)
        .padding(.horizontal, Theme.spacingM)
        .background(Theme.dynamicCardBackground)
        .cornerRadius(Theme.radiusM)
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
                    Text("Add Your First Player")
                        .font(.system(.title, design: .rounded).bold())
                    
                    Text("Great job creating your team! Now, let's add your teammates so you can start splitting matches.")
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
                            Text("Add Player Now")
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

struct PaymentQRSheetView: View {
    let group: BusinessGroup
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()
                
                VStack(spacing: Theme.spacingL) {
                    if let bank = group.bankName,
                       let accName = group.accountName,
                       let accNum = group.accountNumber {
                        
                        let qrString = "Bank: \(bank)\nAccount: \(accNum)\nName: \(accName)"
                        
                        VStack(spacing: Theme.spacingM) {
                            Image(uiImage: QRCodeGenerator().generateQRCode(from: qrString))
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220, height: 220)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                            
                            VStack(spacing: Theme.spacingXS) {
                                Text(bank)
                                    .font(Typography.headline())
                                    .foregroundColor(.white)
                                Text(accNum)
                                    .font(Typography.bodyBold())
                                    .foregroundColor(.white.opacity(0.9))
                                Text(accName.uppercased())
                                    .font(Typography.caption())
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.bottom, Theme.spacingL)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, Theme.spacingXL)
                        .background(Theme.gradientPrimary)
                        .cornerRadius(24)
                        .shadow(color: Theme.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                        .padding(.horizontal, Theme.spacingXL)
                        
                        Text("Show this QR code to your friends so they can scan and pay you directly.")
                            .font(Typography.body())
                            .foregroundColor(Theme.dynamicTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacingXL)
                            .padding(.top, Theme.spacingM)
                        
                    } else {
                        Text("Payment details not set up.")
                            .foregroundColor(Theme.dynamicTextSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.top, Theme.spacingXL)
            }
            .navigationTitle("Payment QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}