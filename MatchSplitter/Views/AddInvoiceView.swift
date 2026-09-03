import SwiftUI
import CoreData

struct AddInvoiceView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @FetchRequest private var clients: FetchedResults<Client>
    
    let groupID: UUID
    
    init(groupID: UUID) {
        self.groupID = groupID
        _clients = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
            predicate: NSPredicate(format: "groupID == %@", groupID as CVarArg),
            animation: .default)
    }
    
    @State private var invoiceNumber: String = ""
    @State private var selectedClient: Client?
    @State private var issueDate: Date = Date()
    @State private var dueDate: Date = Date().addingTimeInterval(30*24*3600)
    @State private var paymentTerms: String = "Net 30"
    @State private var notes: String = ""
    @State private var taxRate: Double = 0.0
    @State private var discount: Double = 0.0
    @State private var items: [TempInvoiceItem] = [TempInvoiceItem()]
    
    var calculatedSubtotal: Double {
        items.reduce(0) { $0 + ($1.quantity * $1.unitPrice) }
    }
    
    var calculatedTotal: Double {
        let sub = calculatedSubtotal
        return sub - discount + (sub * (taxRate / 100.0))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Match Details") {
                    TextField("Split Title (e.g. Wed Night Football)", text: $invoiceNumber)
                    
                    Picker("Player", selection: $selectedClient) {
                        Text("Select Player").tag(nil as Client?)
                        ForEach(clients) { client in
                            Text(client.name).tag(client as Client?)
                        }
                    }
                    
                    DatePicker("Match Date", selection: $issueDate, displayedComponents: .date)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section("Match Expenses") {
                    ForEach($items) { $item in
                        VStack(spacing: 8) {
                            TextField("Item Description", text: $item.itemDescription)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Qty").font(.caption).foregroundColor(.secondary)
                                    TextField("Qty", value: $item.quantity, format: .number)
                                        .keyboardType(.decimalPad)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Price").font(.caption).foregroundColor(.secondary)
                                    TextField("Price", value: $item.unitPrice, format: .number)
                                        .keyboardType(.decimalPad)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("Total").font(.caption).foregroundColor(.secondary)
                                    Text((item.quantity * item.unitPrice).formatted(.currency(code: "VND")))
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        items.remove(atOffsets: indexSet)
                    }
                    
                    Button {
                        items.append(TempInvoiceItem())
                    } label: {
                        Label("Add Item", systemImage: "plus.circle")
                    }
                }
                
                Section("Summary") {
                        HStack {
                            Text("Total Amount")
                                .bold()
                            Spacer()
                            Text(calculatedSubtotal.formatted(.currency(code: "VND")))
                                .bold()
                        }
                    }
                    
                    Section("Notes") {
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                    }
                }
                .hideFormBackground()
                .background(Theme.dynamicBackground.ignoresSafeArea())
                .navigationTitle("New Split")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveInvoice()
                    }
                    .disabled(invoiceNumber.isEmpty)
                }
            }
        }
    }
    
    private func saveInvoice() {
        let invoice = Invoice(context: viewContext)
        invoice.id = UUID()
        invoice.groupID = groupID
        invoice.invoiceNumber = invoiceNumber
        invoice.clientID = selectedClient?.id
        invoice.issueDate = issueDate
        invoice.dueDate = dueDate
        invoice.status = Invoice.InvoiceStatus.draft.rawValue
        invoice.paymentTerms = paymentTerms
        invoice.notes = notes
        invoice.taxRate = taxRate
        invoice.discount = discount
        let subtotal = calculatedSubtotal
        let finalTotal = calculatedTotal
        
        invoice.total = finalTotal
        invoice.subtotal = subtotal
        invoice.taxAmount = subtotal * (taxRate / 100.0)
        invoice.createdAt = Date()
        invoice.updatedAt = Date()
        
        for tempItem in items {
            let item = InvoiceItem(context: viewContext)
            item.id = UUID()
            item.invoiceID = invoice.id
            item.itemDescription = tempItem.itemDescription
            item.quantity = tempItem.quantity
            item.unitPrice = tempItem.unitPrice
            item.taxRate = 0
            item.taxAmount = 0
            item.discount = 0
            item.total = tempItem.quantity * tempItem.unitPrice
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving invoice: \(nsError)")
        }
    }
}

struct TempInvoiceItem: Identifiable {
    var id = UUID()
    var itemDescription: String = ""
    var quantity: Double = 1.0
    var unitPrice: Double = 0.0
}