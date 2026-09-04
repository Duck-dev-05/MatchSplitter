import SwiftUI
import UIKit
import CoreData

// MARK: - InvoiceDetailView

struct InvoiceDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionManager
    @Environment(\.isMember) private var isMember
    @ObservedObject var invoice: Invoice

    @State private var selectedStatus: Invoice.InvoiceStatus
    @FetchRequest private var items:    FetchedResults<InvoiceItem>
    @FetchRequest private var payments: FetchedResults<Payment>
    @State private var client:              Client?
    @State private var showingAddPayment  = false
    @State private var pdfURL:             URL?
    @State private var showShareSheet     = false
    @State private var receiptImage:       UIImage?
    @State private var showImageShareSheet = false
    @State private var showingQRCode      = false

    var totalPayments: Double { payments.reduce(0) { $0 + $1.amount } }
    var balanceDue:    Double { max(0, invoice.total - totalPayments) }

    init(invoice: Invoice) {
        self.invoice = invoice
        _selectedStatus = State(initialValue: invoice.statusEnum)
        _items = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \InvoiceItem.itemDescription, ascending: true)],
            predicate: NSPredicate(format: "invoiceID == %@", invoice.id as CVarArg)
        )
        _payments = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Payment.paymentDate, ascending: true)],
            predicate: NSPredicate(format: "invoiceID == %@", invoice.id as CVarArg)
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.spacingL) {

                        // ── Hero Amount Card ──
                        heroHeader

                        // ── Client Card ──
                        if let client = client {
                            clientCard(client)
                        }

                        // ── Match Dates ──
                        datesCard

                        // ── Expenses ──
                        if !items.isEmpty {
                            expensesCard
                        }

                        // ── Financial Summary ──
                        summaryCard

                        // ── Notes ──
                        if !invoice.notes.isEmpty {
                            notesCard
                        }

                        // ── Payment History ──
                        if !payments.isEmpty {
                            paymentsHistoryCard
                        }

                        // ── Actions ──
                        if balanceDue > 0 {
                            actionsSection
                        }

                        Spacer(minLength: Theme.spacingXXL)
                    }
                    .padding(.vertical)
                }
                .onAppear { loadClient() }
            }
            .navigationTitle("Match Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.primary)
                        .font(Typography.bodyBold())
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            if let url = self.renderAsPDF(fileName: "Invoice_\(invoice.invoiceNumber).pdf") {
                                self.pdfURL = url; self.showShareSheet = true
                            }
                        } label: { Label("Share as PDF", systemImage: "doc.text") }

                        Button {
                            if let group = session.currentGroup, let client = self.client {
                                let rv = InvoiceReceiptView(invoice: invoice, clientName: client.name, group: group, balanceDue: balanceDue)
                                if let img = rv.renderAsImage() {
                                    self.receiptImage = img; self.showImageShareSheet = true
                                }
                            }
                        } label: { Label("Share as Image", systemImage: "photo") }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddPayment) {
                AddPaymentView(invoice: invoice, balanceDue: balanceDue)
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL { ShareSheet(activityItems: [url]) }
                else { EmptyView() }
            }
            .sheet(isPresented: $showImageShareSheet) {
                if let img = receiptImage { ShareSheet(activityItems: [img]) }
                else { EmptyView() }
            }
            .sheet(isPresented: $showingQRCode) {
                if let group = session.currentGroup {
                    InvoiceQRView(group: group, invoice: invoice, balanceDue: balanceDue)
                } else {
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Sections

    private var heroHeader: some View {
        VStack(spacing: Theme.spacingM) {
            // Invoice number pill
            Text(invoice.invoiceNumber.uppercased())
                .tracking(1.5)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Theme.dynamicTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Theme.dynamicCardBackground)
                .cornerRadius(Theme.radiusXL)

            // Amount
            VStack(spacing: 4) {
                Text((balanceDue > 0 ? "Balance Due" : "Fully Paid").uppercased())
                    .tracking(0.5)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(balanceDue > 0 ? Theme.dynamicTextSecondary : Theme.success)
                Text(balanceDue.formatted(.currency(code: "VND")))
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(balanceDue > 0 ? Theme.dynamicTextPrimary : Theme.success)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            // Status picker
            HStack {
                Label("Status", systemImage: "flag.fill")
                    .font(Typography.captionBold())
                    .foregroundColor(Theme.primary)
                Spacer()
                Picker("Status", selection: $selectedStatus) {
                    ForEach(Invoice.InvoiceStatus.allCases, id: \.self) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.primary)
                .disabled(isMember)
                .onChange(of: selectedStatus) { newValue in
                    invoice.statusEnum = newValue
                    invoice.updatedAt  = Date()
                    try? viewContext.save()
                }
            }
            .padding(Theme.spacingM)
            .background(Theme.dynamicCardBackground)
            .cornerRadius(Theme.radiusL)
        }
        .padding(Theme.spacingL)
        .frame(maxWidth: .infinity)
        .background(Theme.dynamicBackground)
        .padding(.horizontal)
    }

    private func clientCard(_ client: Client) -> some View {
        HStack(spacing: Theme.spacingM) {
            // Avatar
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
                    .frame(width: 50, height: 50)
                Text(String(client.name.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("PLAYER")
                    .tracking(0.5)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.dynamicTextSecondary)
                Text(client.name)
                    .font(Typography.bodyBold())
                if !client.email.isEmpty {
                    Text(client.email)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Theme.dynamicTextSecondary)
                }
            }
            Spacer()
        }
        .padding(Theme.spacingM)
        .cardStyle()
        .padding(.horizontal)
    }

    private var datesCard: some View {
        HStack {
            dateBlock(label: "Match Date", date: invoice.issueDate, isOverdue: false)
            Spacer()
            Divider()
            Spacer()
            dateBlock(label: "Due Date", date: invoice.dueDate, isOverdue: invoice.isOverdue)
        }
        .padding(Theme.spacingM)
        .cardStyle()
        .padding(.horizontal)
    }

    private func dateBlock(label: String, date: Date, isOverdue: Bool) -> some View {
        VStack(spacing: 4) {
            Text(label.uppercased())
                .tracking(0.4)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.dynamicTextSecondary)
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(Typography.bodyBold())
                .foregroundColor(isOverdue ? Theme.error : Theme.dynamicTextPrimary)
            if isOverdue {
                Text("OVERDUE")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Theme.error)
                    .cornerRadius(20)
            }
        }
    }

    private var expensesCard: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundColor(Theme.primary)
                    .font(.system(size: 13, weight: .semibold))
                Text("Match Expenses")
                    .font(Typography.subheadlineBold())
            }
            .padding(.bottom, 2)

            ForEach(items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.itemDescription)
                            .font(Typography.bodyBold())
                        Text("\(item.quantity, specifier: "%g") × \(item.unitPrice.formatted(.currency(code: "VND")))")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Theme.dynamicTextSecondary)
                    }
                    Spacer()
                    Text(item.total.formatted(.currency(code: "VND")))
                        .font(Typography.bodyBold())
                        .foregroundColor(Theme.dynamicTextPrimary)
                }
                if item.id != items.last?.id {
                    Divider()
                }
            }
        }
        .padding(Theme.spacingM)
        .cardStyle()
        .padding(.horizontal)
    }

    private var summaryCard: some View {
        VStack(spacing: Theme.spacingM) {
            // Subtotal
            summaryRow(label: "Subtotal", value: invoice.subtotal.formatted(.currency(code: "VND")), isTotal: false)

            if invoice.taxRate > 0 {
                summaryRow(label: "Tax (\(String(format: "%.1f", invoice.taxRate))%)", value: invoice.taxAmount.formatted(.currency(code: "VND")), isTotal: false)
            }

            if invoice.discount > 0 {
                summaryRow(label: "Discount", value: "-\(invoice.discount.formatted(.currency(code: "VND")))", isTotal: false, color: Theme.success)
            }

            Divider()

            summaryRow(label: "Total Match Cost", value: invoice.total.formatted(.currency(code: "VND")), isTotal: true)

            if totalPayments > 0 {
                summaryRow(label: "Paid", value: "-\(totalPayments.formatted(.currency(code: "VND")))", isTotal: false, color: Theme.success)
                Divider()
                summaryRow(label: "Balance Due", value: balanceDue.formatted(.currency(code: "VND")), isTotal: true, color: Theme.primary)
            }
        }
        .padding(Theme.spacingM)
        .cardStyle()
        .padding(.horizontal)
    }

    private func summaryRow(label: String, value: String, isTotal: Bool, color: Color? = nil) -> some View {
        HStack {
            Text(label)
                .font(isTotal ? Typography.bodyBold() : Typography.body())
                .foregroundColor(color ?? Theme.dynamicTextPrimary)
            Spacer()
            Text(value)
                .font(isTotal ? Typography.bodyBold() : Typography.body())
                .foregroundColor(color ?? (isTotal ? Theme.dynamicTextPrimary : Theme.dynamicTextSecondary))
        }
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(Theme.primary)
                    .font(.system(size: 13, weight: .semibold))
                Text("Notes")
                    .font(Typography.subheadlineBold())
            }
            Text(invoice.notes)
                .font(Typography.body())
                .foregroundColor(Theme.dynamicTextSecondary)
        }
        .padding(Theme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .padding(.horizontal)
    }

    private var paymentsHistoryCard: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(Theme.success)
                    .font(.system(size: 13, weight: .semibold))
                Text("Payment History")
                    .font(Typography.subheadlineBold())
            }

            ForEach(payments) { payment in
                HStack(spacing: Theme.spacingM) {
                    ZStack {
                        Circle()
                            .fill(Theme.success.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Theme.success)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(payment.paymentDate.formatted(date: .abbreviated, time: .omitted))
                            .font(Typography.bodyBold())
                        Text(payment.paymentMethod)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Theme.dynamicTextSecondary)
                    }
                    Spacer()
                    Text(payment.amount.formatted(.currency(code: "VND")))
                        .font(Typography.bodyBold())
                        .foregroundColor(Theme.success)
                }
                if payment.id != payments.last?.id { Divider() }
            }
        }
        .padding(Theme.spacingM)
        .cardStyle()
        .padding(.horizontal)
    }

    private var actionsSection: some View {
        VStack(spacing: Theme.spacingM) {
            if !isMember {
                Button {
                    showingAddPayment = true
                } label: {
                    Label("Mark as Paid", systemImage: "checkmark.circle.fill")
                        .font(Typography.button())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.gradientPrimary)
                        .cornerRadius(Theme.radiusXL)
                        .shadow(color: Theme.primary.opacity(0.35), radius: 12, x: 0, y: 5)
                }
            }

            if let bank = session.currentGroup?.bankName, !bank.isEmpty,
               let accNum = session.currentGroup?.accountNumber, !accNum.isEmpty {
                Button {
                    showingQRCode = true
                } label: {
                    Label("Show Payment QR", systemImage: "qrcode")
                        .font(Typography.button())
                        .foregroundColor(Theme.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primary.opacity(0.10))
                        .cornerRadius(Theme.radiusXL)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusXL)
                                .stroke(Theme.primary.opacity(0.25), lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal)
    }

    private func loadClient() {
        guard let clientId = invoice.clientID else { return }
        let request = Client.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", clientId as CVarArg)
        self.client = try? viewContext.fetch(request).first
    }
}

// MARK: - AddPaymentView

struct AddPaymentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let invoice:       Invoice
    let initialAmount: Double

    @State private var amount:          Double
    @State private var paymentDate:     Date              = Date()
    @State private var paymentMethod:   Payment.PaymentMethod = .bankTransfer
    @State private var referenceNumber: String            = ""
    @State private var notes:           String            = ""

    init(invoice: Invoice, balanceDue: Double) {
        self.invoice       = invoice
        self.initialAmount = balanceDue
        _amount = State(initialValue: balanceDue)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Payment Details").font(Typography.captionBold())) {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("₫", value: $amount, format: .currency(code: "VND"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    DatePicker("Payment Date", selection: $paymentDate, displayedComponents: .date)
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(Payment.PaymentMethod.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    TextField("Reference Number", text: $referenceNumber)
                }
                Section(header: Text("Notes").font(Typography.captionBold())) {
                    TextEditor(text: $notes).frame(minHeight: 80)
                }
            }
            .hideFormBackground()
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Mark as Paid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.dynamicTextSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { savePayment() }
                        .font(Typography.bodyBold())
                        .foregroundColor(Theme.primary)
                        .disabled(amount <= 0)
                }
            }
        }
    }

    private func savePayment() {
        let payment = Payment(context: viewContext)
        payment.id              = UUID()
        payment.groupID         = invoice.groupID
        payment.invoiceID       = invoice.id
        payment.amount          = amount
        payment.paymentDate     = paymentDate
        payment.methodEnum      = paymentMethod
        payment.referenceNumber = referenceNumber
        payment.notes           = notes
        payment.createdAt       = Date()
        invoice.statusEnum      = amount >= initialAmount ? .paid : .partial
        invoice.updatedAt       = Date()
        try? viewContext.save()
        dismiss()
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems:        [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - PDF Render Extension

extension View {
    @MainActor
    func renderAsPDF(fileName: String = "Invoice.pdf") -> URL? {
        let controller = UIHostingController(rootView: self)
        guard let view = controller.view else { return nil }
        let targetSize = CGSize(width: 595.2, height: 841.8)
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .white
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: targetSize))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
            return url
        } catch {
            print("PDF error: \(error)")
            return nil
        }
    }
}

// MARK: - InvoiceQRView

struct InvoiceQRView: View {
    @Environment(\.dismiss) private var dismiss
    let group:     BusinessGroup
    let invoice:   Invoice
    let balanceDue: Double

    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()

                VStack(spacing: Theme.spacingL) {
                    Text("Have your friends scan this code to pay the remaining balance.")
                        .font(Typography.caption())
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacingXL)
                        .padding(.top, Theme.spacingL)

                    let bank     = group.bankName      ?? ""
                    let accNum   = group.accountNumber ?? ""
                    let accName  = group.accountName   ?? ""
                    let qrString = "Bank: \(bank)\nAccount: \(accNum)\nName: \(accName)\nAmount: \(Int(balanceDue))\nRef: \(invoice.invoiceNumber)"

                    VStack(spacing: Theme.spacingM) {
                        if let qrImg = QRGenerator.generateQRCode(from: qrString) {
                            Image(uiImage: qrImg)
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
                                .tracking(1.2)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.65))

                            Divider().background(Color.white.opacity(0.25)).padding(.vertical, 6)

                            Text("Due: \(balanceDue.formatted(.currency(code: "VND")))")
                                .font(Typography.subheadlineBold())
                                .foregroundColor(.white)
                            Text("Ref: \(invoice.invoiceNumber)")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .padding(.bottom, Theme.spacingL)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, Theme.spacingXL)
                    .background(Theme.gradientPrimary)
                    .cornerRadius(Theme.radiusXXL)
                    .shadow(color: Theme.primary.opacity(0.4), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, Theme.spacingXL)

                    Spacer()
                }
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