import SwiftUI
import CoreData

struct InvoiceDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionManager
    @ObservedObject var invoice: Invoice
    
    @State private var selectedStatus: Invoice.InvoiceStatus
    @FetchRequest private var items: FetchedResults<InvoiceItem>
    @FetchRequest private var payments: FetchedResults<Payment>
    @State private var client: Client?
    @State private var showingAddPayment = false
    
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var showingQRCode = false
    
    var totalPayments: Double {
        payments.reduce(0) { $0 + $1.amount }
    }
    
    var balanceDue: Double {
        max(0, invoice.total - totalPayments)
    }
    
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Invoice Header
                        VStack(alignment: .leading, spacing: 12) {
                            Text(invoice.invoiceNumber)
                                .font(.system(.title2, design: .rounded).bold())
                            
                            HStack {
                                Label("Status", systemImage: "flag.fill")
                                    .font(.system(.subheadline, design: .rounded).bold())
                                    .foregroundColor(Theme.primary)
                                
                                Spacer()
                                
                                Picker("Status", selection: $selectedStatus) {
                                    ForEach(Invoice.InvoiceStatus.allCases, id: \.self) { status in
                                        Text(status.rawValue).tag(status)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Theme.primary)
                                .onChange(of: selectedStatus) { newValue in
                                    invoice.statusEnum = newValue
                                    invoice.updatedAt = Date()
                                    try? viewContext.save()
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()
                        
                        // Client Info
                        if let client = client {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Player")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.secondary)
                                Text(client.name)
                                    .font(.system(.headline, design: .rounded).bold())
                                if !client.email.isEmpty {
                                    Text(client.email)
                                        .font(.system(.subheadline, design: .rounded))
                                }
                                if !client.address.isEmpty {
                                    Text(client.address)
                                        .font(.system(.subheadline, design: .rounded))
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cardStyle()
                        }
                        
                        // Match Details
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Match Date")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.secondary)
                                    Text(invoice.issueDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(.subheadline, design: .rounded).bold())
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Due Date")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.secondary)
                                    Text(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(.subheadline, design: .rounded).bold())
                                        .foregroundColor(invoice.isOverdue ? .red : .primary)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Payment Terms")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(invoice.paymentTerms)
                                    .font(.system(.subheadline, design: .rounded).bold())
                            }
                        }
                        .padding(16)
                        .cardStyle()
                        
                        // Match Expenses
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Match Expenses")
                                    .font(.system(.headline, design: .rounded).bold())
                                    .foregroundColor(Theme.primary)
                                
                                ForEach(items) { item in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(item.itemDescription)
                                                .font(.system(.subheadline, design: .rounded).bold())
                                            Text("\(item.quantity, specifier: "%g") x \(item.unitPrice.formatted(.currency(code: "VND")))")
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(item.total.formatted(.currency(code: "VND")))
                                            .font(.system(.subheadline, design: .rounded))
                                    }
                                    if item.id != items.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cardStyle()
                        }
                        
                        // Financial Summary
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Subtotal")
                                    .font(.system(.subheadline, design: .rounded))
                                Spacer()
                                Text(invoice.subtotal.formatted(.currency(code: "VND")))
                                    .font(.system(.subheadline, design: .rounded))
                            }
                            
                            HStack {
                                Text("Tax (\(invoice.taxRate, specifier: "%.1f")%)")
                                    .font(.system(.subheadline, design: .rounded))
                                Spacer()
                                Text(invoice.taxAmount.formatted(.currency(code: "VND")))
                                    .font(.system(.subheadline, design: .rounded))
                            }
                            
                            if invoice.discount > 0 {
                                HStack {
                                    Text("Discount")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.green)
                                    Spacer()
                                    Text("-\(invoice.discount.formatted(.currency(code: "VND")))")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Total Match Cost")
                                    .font(.system(.title3, design: .rounded).bold())
                                Spacer()
                                Text(invoice.total.formatted(.currency(code: "VND")))
                                    .font(.system(.title3, design: .rounded).bold())
                            }
                            
                            if totalPayments > 0 {
                                HStack {
                                    Text("Payments")
                                        .font(.system(.subheadline, design: .rounded))
                                    Spacer()
                                    Text("-\(totalPayments.formatted(.currency(code: "VND")))")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Balance Due")
                                    .font(.system(.title3, design: .rounded).bold())
                                Spacer()
                                Text(balanceDue.formatted(.currency(code: "VND")))
                                    .font(.system(.title3, design: .rounded).bold())
                                    .foregroundColor(Theme.primary)
                            }
                        }
                        .padding(16)
                        .cardStyle()
                        
                        // Notes
                        if !invoice.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.system(.headline, design: .rounded).bold())
                                    .foregroundColor(Theme.primary)
                                Text(invoice.notes)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cardStyle()
                        }
                        
                        // Payments History
                        if !payments.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Payment History")
                                    .font(.system(.headline, design: .rounded).bold())
                                    .foregroundColor(Theme.primary)
                                
                                ForEach(payments) { payment in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(payment.paymentDate.formatted(date: .abbreviated, time: .omitted))
                                                .font(.system(.subheadline, design: .rounded).bold())
                                            Text(payment.paymentMethod)
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(payment.amount.formatted(.currency(code: "VND")))
                                            .font(.system(.subheadline, design: .rounded))
                                    }
                                    if payment.id != payments.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cardStyle()
                        }
                        
                        if balanceDue > 0 {
                            VStack(spacing: 12) {
                                Button {
                                    showingAddPayment = true
                                } label: {
                                    Text("Mark as Paid")
                                        .font(.system(.headline, design: .rounded).bold())
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Theme.primary)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                
                                if let bank = session.currentGroup?.bankName,
                                   let accNum = session.currentGroup?.accountNumber,
                                   !bank.isEmpty, !accNum.isEmpty {
                                    Button {
                                        showingQRCode = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "qrcode")
                                            Text("Show Payment QR")
                                        }
                                        .font(.system(.headline, design: .rounded).bold())
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Theme.secondary.opacity(0.15))
                                        .foregroundColor(Theme.secondary)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    loadClient()
                }
            }
            .navigationTitle("Match Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Render a simple version without the done/share buttons
                        let pdfView = AnyView(self.body) // Might be recursive, better to render a specific InvoicePDFView if we had one.
                        // Actually, for simplicity on iOS 15, we can just share self
                        if let url = self.renderAsPDF(fileName: "Invoice_\(invoice.invoiceNumber).pdf") {
                            self.pdfURL = url
                            self.showShareSheet = true
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddPayment) {
                AddPaymentView(invoice: invoice, balanceDue: balanceDue)
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .sheet(isPresented: $showingQRCode) {
                if let group = session.currentGroup {
                    InvoiceQRView(group: group, invoice: invoice, balanceDue: balanceDue)
                }
            }
        }
    }
    
    private func loadClient() {
        guard let clientId = invoice.clientID else { return }
        let request = Client.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", clientId as CVarArg)
        if let fetchedClient = try? viewContext.fetch(request).first {
            self.client = fetchedClient
        }
    }
}

struct AddPaymentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let invoice: Invoice
    let initialAmount: Double
    
    @State private var amount: Double
    @State private var paymentDate: Date = Date()
    @State private var paymentMethod: Payment.PaymentMethod = .bankTransfer
    @State private var referenceNumber: String = ""
    @State private var notes: String = ""
    
    init(invoice: Invoice, balanceDue: Double) {
        self.invoice = invoice
        self.initialAmount = balanceDue
        _amount = State(initialValue: balanceDue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Payment Details") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("₫", value: $amount, format: .currency(code: "VND"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Payment Date", selection: $paymentDate, displayedComponents: .date)
                    
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(Payment.PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    
                    TextField("Reference Number", text: $referenceNumber)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Mark as Paid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePayment()
                    }
                    .disabled(amount <= 0)
                }
            }
        }
    }
    
    private func savePayment() {
        let payment = Payment(context: viewContext)
        payment.id = UUID()
        payment.groupID = invoice.groupID
        payment.invoiceID = invoice.id
        payment.amount = amount
        payment.paymentDate = paymentDate
        payment.methodEnum = paymentMethod
        payment.referenceNumber = referenceNumber
        payment.notes = notes
        payment.createdAt = Date()
        
        // Update invoice status if fully paid
        if amount >= initialAmount {
            invoice.statusEnum = .paid
        } else {
            invoice.statusEnum = .partial
        }
        invoice.updatedAt = Date()
        
        try? viewContext.save()
        dismiss()
    }
}

import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension View {
    @MainActor
    func renderAsPDF(fileName: String = "Invoice.pdf") -> URL? {
        let controller = UIHostingController(rootView: self)
        guard let view = controller.view else { return nil }
        
        let targetSize = CGSize(width: 595.2, height: 841.8) // A4 size
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .white
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: targetSize))
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
            return url
        } catch {
            print("Could not create PDF: \(error)")
            return nil
        }
    }
}

struct InvoiceQRView: View {
    @Environment(\.dismiss) private var dismiss
    let group: BusinessGroup
    let invoice: Invoice
    let balanceDue: Double
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()
                
                VStack(spacing: Theme.spacingL) {
                    Text("Have your friends scan this code to pay the remaining balance.")
                        .font(Typography.body())
                        .foregroundColor(Theme.dynamicTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacingL)
                        .padding(.top, Theme.spacingL)
                    
                    let bank = group.bankName ?? ""
                    let accNum = group.accountNumber ?? ""
                    let accName = group.accountName ?? ""
                    
                    // Note: In Vietnam, standardized VietQR format could be used here for auto-fill in banking apps.
                    // For now, it outputs a readable text string with invoice reference.
                    let qrString = "Bank: \(bank)\nAccount: \(accNum)\nName: \(accName)\nAmount: \(Int(balanceDue))\nRef: \(invoice.invoiceNumber)"
                    
                    VStack(spacing: Theme.spacingM) {
                        Image(uiImage: QRCodeGenerator().generateQRCode(from: qrString))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                        
                        VStack(spacing: 4) {
                            Text(bank)
                                .font(Typography.headline())
                                .foregroundColor(.white)
                            Text(accNum)
                                .font(Typography.bodyBold())
                                .foregroundColor(.white.opacity(0.9))
                            Text(accName.uppercased())
                                .font(Typography.caption())
                                .foregroundColor(.white.opacity(0.7))
                            
                            Divider().background(Color.white.opacity(0.3)).padding(.vertical, 8)
                            
                            Text("Amount Due: \(balanceDue.formatted(.currency(code: "VND")))")
                                .font(Typography.subheadlineBold())
                                .foregroundColor(.white)
                            Text("Ref: \(invoice.invoiceNumber)")
                                .font(Typography.caption())
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.bottom, Theme.spacingM)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, Theme.spacingL)
                    .background(Theme.gradientPrimary)
                    .cornerRadius(24)
                    .shadow(color: Theme.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                    .padding(.horizontal, Theme.spacingXL)
                    
                    Spacer()
                }
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