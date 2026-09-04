import SwiftUI
import CoreData

// MARK: - DashboardView

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var session: SessionManager
    @AppStorage private var hasSeenClientOnboarding: Bool
    @State private var showingClientOnboarding = false
    @State private var showingPaymentQR        = false
    @State private var showingTeamInviteQR     = false

    @FetchRequest private var invoices:  FetchedResults<Invoice>
    @FetchRequest private var payments:  FetchedResults<Payment>
    @FetchRequest private var clients:   FetchedResults<Client>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BusinessGroup.name, ascending: true)],
        animation: .default
    ) private var allGroups: FetchedResults<BusinessGroup>

    var myGroups: [BusinessGroup] {
        guard let userID = session.currentUser?.id else { return [] }
        return allGroups.filter { $0.ownerID == userID }
    }

    let groupID: UUID

    init(groupID: UUID) {
        self.groupID = groupID
        let predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        _invoices = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.createdAt, ascending: false)],
            predicate: predicate, animation: .default)
        _payments = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Payment.paymentDate, ascending: false)],
            predicate: predicate, animation: .default)
        _clients = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
            predicate: predicate, animation: .default)
        self._hasSeenClientOnboarding = AppStorage(wrappedValue: false, "hasSeenClientOnboarding_\(groupID.uuidString)")
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.spacingL) {

                        // ── Hero Balance Card ──
                        heroBalanceSection

                        // ── Quick Stats Row ──
                        HStack(spacing: Theme.spacingM) {
                            SummaryCard(
                                title: "Collected",
                                amount: totalRevenue,
                                icon: "checkmark.circle.fill",
                                color: Theme.success
                            )
                            SummaryCard(
                                title: "Pending",
                                amount: Double(pendingInvoicesCount),
                                icon: "clock.fill",
                                color: Theme.warning,
                                isCurrency: false
                            )
                        }
                        .padding(.horizontal)

                        // ── Leaderboard Link ──
                        if !clients.isEmpty {
                            NavigationLink(destination: LeaderboardView(groupID: groupID)) {
                                HStack(spacing: Theme.spacingM) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.yellow.opacity(0.18))
                                            .frame(width: 48, height: 48)
                                        Image(systemName: "trophy.fill")
                                            .font(.title3)
                                            .foregroundColor(.yellow)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Team Leaderboard")
                                            .font(Typography.bodyBold())
                                            .foregroundColor(Theme.dynamicTextPrimary)
                                        Text("MVP · biggest spender · best payer")
                                            .font(Typography.caption())
                                            .foregroundColor(Theme.dynamicTextSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Theme.primary.opacity(0.6))
                                }
                                .padding(Theme.spacingM)
                                .cardStyle()
                            }
                            .padding(.horizontal)
                        }

                        // ── Recent Splits ──
                        sectionHeader("Recent Splits", icon: "doc.text.fill")

                        if recentInvoices.isEmpty {
                            dashEmptyState(message: "No splits yet — add the first one!", icon: "sportscourt")
                        } else {
                            VStack(spacing: Theme.spacingS) {
                                ForEach(recentInvoices.prefix(5)) { invoice in
                                    InvoiceRowView(invoice: invoice, clients: clients)
                                }
                            }
                            .padding(.horizontal)
                        }

                        // ── Recent Activity ──
                        sectionHeader("Recent Activity", icon: "arrow.down.left.circle.fill")

                        if recentPayments.isEmpty {
                            dashEmptyState(message: "No payments yet", icon: "clock.arrow.circlepath")
                        } else {
                            VStack(spacing: Theme.spacingS) {
                                ForEach(recentPayments.prefix(5)) { payment in
                                    PaymentRowView(payment: payment, invoices: invoices)
                                }
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: Theme.spacingXXL)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(myGroups) { group in
                            Button {
                                withAnimation { session.selectGroup(group: group) }
                            } label: {
                                HStack {
                                    Text(group.name)
                                    if group.id == session.currentGroup?.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        Divider()
                        Button {
                            withAnimation { session.clearGroup() }
                        } label: {
                            Label("Manage Teams...", systemImage: "building.2.crop.circle")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(session.currentGroup?.name ?? "My Team")
                                .font(Typography.headline())
                                .foregroundColor(Theme.primary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Theme.primary)
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingClientOnboarding) {
            FirstClientOnboardingView(groupID: groupID, isPresented: $showingClientOnboarding)
                .onDisappear { hasSeenClientOnboarding = true }
        }
        .sheet(isPresented: $showingPaymentQR) {
            if let group = session.currentGroup {
                PaymentQRSheetView(group: group)
            }
        }
        .sheet(isPresented: $showingTeamInviteQR) {
            if let group = session.currentGroup {
                TeamQRInviteView(group: group)
            }
        }
    }

    // MARK: - Hero Balance

    private var heroBalanceSection: some View {
        ZStack {
            // Background gradient card
            RoundedRectangle(cornerRadius: Theme.radiusXXL)
                .fill(Theme.gradientPrimary)
                .shadow(color: Theme.primary.opacity(0.4), radius: 20, x: 0, y: 10)

            // Subtle pattern overlay
            RoundedRectangle(cornerRadius: Theme.radiusXXL)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.clear],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: Theme.spacingM) {
                // Team name + player count
                if let group = session.currentGroup {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(group.name.uppercased())
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.75))
                                .tracking(1.5)
                            Text("\(clients.count) Player\(clients.count == 1 ? "" : "s")")
                                .font(Typography.caption())
                                .foregroundColor(.white.opacity(0.65))
                        }
                        Spacer()
                        Text("Since \(group.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }

                // Outstanding amount
                VStack(spacing: 4) {
                    Text("Outstanding")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                        .tracking(0.5)
                    Text(outstandingAmount.formatted(.currency(code: "VND")))
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Circle().fill(.white.opacity(0.6)).frame(width: 6, height: 6)
                        Text("Collected: \(totalRevenue.formatted(.currency(code: "VND")))")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.white.opacity(0.75))
                    }
                }

                // Action Buttons
                if clients.isEmpty {
                    Button {
                        showingClientOnboarding = true
                    } label: {
                        Label("Add First Player", systemImage: "person.badge.plus")
                            .font(Typography.button())
                            .foregroundColor(Theme.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(Theme.radiusXL)
                    }
                    .padding(.top, Theme.spacingXS)
                } else {
                    HStack(spacing: Theme.spacingM) {
                        Button {
                            showingTeamInviteQR = true
                        } label: {
                            Label("Invite", systemImage: "person.badge.plus")
                                .font(Typography.button())
                                .foregroundColor(Theme.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.radiusXL)
                        }

                        if let bank = session.currentGroup?.bankName, !bank.isEmpty {
                            Button {
                                showingPaymentQR = true
                            } label: {
                                Label("Receive", systemImage: "qrcode")
                                    .font(Typography.button())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(Theme.radiusXL)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.radiusXL)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.top, Theme.spacingXS)
                }
            }
            .padding(Theme.spacingL)
        }
        .padding(.horizontal)
        .padding(.top, Theme.spacingS)
    }

    // MARK: - Subviews

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.primary)
            Text(title)
                .font(Typography.subheadlineBold())
                .foregroundColor(Theme.dynamicTextPrimary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private func dashEmptyState(message: String, icon: String) -> some View {
        VStack(spacing: Theme.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(Theme.dynamicTextSecondary.opacity(0.4))
            Text(message)
                .font(Typography.caption())
                .foregroundColor(Theme.dynamicTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXL)
        .cardStyle()
        .padding(.horizontal)
    }

    // MARK: - Computed Properties

    var totalRevenue: Double {
        payments.reduce(0.0) { $0 + $1.amount }
    }

    var outstandingAmount: Double {
        invoices.filter { !$0.isPaid }.reduce(0.0) { result, invoice in
            let paidAmount = payments.filter { $0.invoiceID == invoice.id }.reduce(0.0) { $0 + $1.amount }
            return result + (invoice.total - paidAmount)
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
        return payments.filter { calendar.isDate($0.paymentDate, equalTo: now, toGranularity: .month) }
                       .reduce(0.0) { $0 + $1.amount }
    }

    var recentInvoices: [Invoice] {
        Array(invoices).sorted { $0.createdAt > $1.createdAt }
    }

    var recentPayments: [Payment] {
        Array(payments).sorted { $0.paymentDate > $1.paymentDate }
    }
}

// MARK: - SummaryCard

struct SummaryCard: View {
    let title:   String
    let amount:  Double
    let icon:    String
    var color:       Color = Theme.primary
    var isCurrency:  Bool  = true
    var isPrimary:   Bool  = false

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.radiusS)
                        .fill(isPrimary ? Color.white.opacity(0.2) : color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isPrimary ? .white : color)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(isPrimary ? .white.opacity(0.75) : Theme.dynamicTextSecondary)

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
                .minimumScaleFactor(0.75)
            }
        }
        .padding(Theme.spacingM)
        .background(
            Group {
                if isPrimary { AnyView(Theme.gradientPrimary) }
                else { AnyView(Theme.dynamicCardBackground) }
            }
        )
        .cornerRadius(Theme.radiusXL)
        .shadow(
            color: isPrimary ? Theme.primary.opacity(0.3) : Color.black.opacity(colorScheme == .dark ? 0.28 : 0.06),
            radius: 10, x: 0, y: 5
        )
    }
}

// MARK: - InvoiceRowView

struct InvoiceRowView: View {
    let invoice: Invoice
    let clients: FetchedResults<Client>

    var clientName: String {
        clients.first(where: { $0.id == invoice.clientID })?.name ?? "Unknown Player"
    }

    var statusColor: Color {
        switch invoice.statusEnum {
        case .paid:         return Theme.success
        case .partial:      return Theme.warning
        case .overdue:      return Theme.error
        case .sent, .viewed: return Theme.primary
        default:            return Theme.dynamicTextSecondary
        }
    }

    var body: some View {
        HStack(spacing: Theme.spacingM) {
            // Left status accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(statusColor)
                .frame(width: 3, height: 40)

            // Avatar
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.12))
                    .frame(width: 42, height: 42)
                Text(String(clientName.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(clientName)
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.dynamicTextPrimary)
                Text(invoice.invoiceNumber)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Theme.dynamicTextSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(invoice.total.formatted(.currency(code: "VND")))
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.dynamicTextPrimary)

                // Status pill
                Text(invoice.status.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.12))
                    .cornerRadius(20)
            }
        }
        .padding(.vertical, Theme.spacingS)
        .padding(.horizontal, Theme.spacingM)
        .background(Theme.dynamicCardBackground)
        .cornerRadius(Theme.radiusL)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - PaymentRowView

struct PaymentRowView: View {
    let payment:  Payment
    let invoices: FetchedResults<Invoice>

    var invoiceNumber: String {
        invoices.first(where: { $0.id == payment.invoiceID })?.invoiceNumber ?? "Unknown Split"
    }

    var body: some View {
        HStack(spacing: Theme.spacingM) {
            ZStack {
                Circle()
                    .fill(Theme.success.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: "arrow.down.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.success)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(invoiceNumber)
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.dynamicTextPrimary)
                Text(payment.paymentMethod)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Theme.dynamicTextSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(payment.amount.formatted(.currency(code: "VND")))")
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.success)
                Text(payment.paymentDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Theme.dynamicTextSecondary)
            }
        }
        .padding(.vertical, Theme.spacingS)
        .padding(.horizontal, Theme.spacingM)
        .background(Theme.dynamicCardBackground)
        .cornerRadius(Theme.radiusL)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - FirstClientOnboardingView

struct FirstClientOnboardingView: View {
    let groupID: UUID
    @Binding var isPresented: Bool
    @FetchRequest private var clients: FetchedResults<Client>
    @State private var showingAddClient = false

    init(groupID: UUID, isPresented: Binding<Bool>) {
        self.groupID    = groupID
        self._isPresented = isPresented
        let predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        _clients = FetchRequest(sortDescriptors: [], predicate: predicate, animation: .default)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.primary.opacity(0.12), Theme.dynamicBackground],
                startPoint: .top, endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: Theme.spacingXL) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Theme.gradientPrimary)
                        .frame(width: 130, height: 130)
                        .shadow(color: Theme.primary.opacity(0.4), radius: 20, x: 0, y: 10)
                    Image(systemName: "person.2.badge.plus")
                        .font(.system(size: 54, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(spacing: Theme.spacingM) {
                    Text("Add Your First Player")
                        .font(Typography.largeTitle())
                        .multilineTextAlignment(.center)
                    Text("Great job creating your team! Add teammates to start splitting matches.")
                        .font(Typography.body())
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacingXL)
                }

                Spacer()

                VStack(spacing: Theme.spacingM) {
                    Button {
                        showingAddClient = true
                    } label: {
                        Label("Add Player Now", systemImage: "plus.circle.fill")
                            .font(Typography.button())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.gradientPrimary)
                            .cornerRadius(Theme.radiusXL)
                            .shadow(color: Theme.primary.opacity(0.35), radius: 12, x: 0, y: 5)
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
            if count > 0 { isPresented = false }
        }
    }
}

// MARK: - PaymentQRSheetView

struct PaymentQRSheetView: View {
    let group: BusinessGroup
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()

                VStack(spacing: Theme.spacingL) {
                    if let bank   = group.bankName,
                       let accName = group.accountName,
                       let accNum  = group.accountNumber {

                        let qrString = "Bank: \(bank)\nAccount: \(accNum)\nName: \(accName)"

                        VStack(spacing: Theme.spacingM) {
                            if let qrImage = QRGenerator.generateQRCode(from: qrString) {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 220, height: 220)
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(Theme.radiusL)
                                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                            }

                            VStack(spacing: 4) {
                                Text(bank)
                                    .font(Typography.headline())
                                    .foregroundColor(.white)
                                Text(accNum)
                                    .font(Typography.bodyBold())
                                    .foregroundColor(.white.opacity(0.9))
                                Text(accName.uppercased())
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.65))
                                    .tracking(1.2)
                            }
                            .padding(.bottom, Theme.spacingL)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, Theme.spacingXL)
                        .background(Theme.gradientPrimary)
                        .cornerRadius(Theme.radiusXXL)
                        .shadow(color: Theme.primary.opacity(0.4), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, Theme.spacingXL)

                        Text("Show this QR code so friends can scan and pay you directly.")
                            .font(Typography.caption())
                            .foregroundColor(Theme.dynamicTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacingXL)
                            .padding(.top, Theme.spacingS)

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
                        .font(Typography.bodyBold())
                        .foregroundColor(Theme.primary)
                }
            }
        }
    }
}