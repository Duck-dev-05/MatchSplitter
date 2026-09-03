import SwiftUI
import CoreData

struct AddInvoiceView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
        animation: .default)
    private var clients: FetchedResults<Client>
    
    @State private var invoiceNumber: String = ""
    @State private var selectedClient: Client?
    @State private var issueDate: Date = Date()
    @State private var dueDate: Date = Date().addingTimeInterval(30*24*3600)
    @State private var paymentTerms: String = "Net 30"
    @State private var notes: String = ""
    @State private var taxRate: Double = 0.0
    @State private var discount: Double = 0.0
    @State private var total: Double = 0.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Invoice Details") {
                    TextField("Invoice Number", text: $invoiceNumber)
                    
                    Picker("Client", selection: $selectedClient) {
                        Text("Select Client").tag(nil as Client?)
                        ForEach(clients) { client in
                            Text(client.name).tag(client as Client?)
                        }
                    }
                    
                    DatePicker("Issue Date", selection: $issueDate, displayedComponents: .date)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    
                    TextField("Payment Terms", text: $paymentTerms)
                }
                
                Section("Financials") {
                    HStack {
                        Text("Total Amount")
                        Spacer()
                        TextField("$", value: $total, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Tax Rate")
                        Spacer()
                        TextField("%", value: $taxRate, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text("Discount")
                        Spacer()
                        TextField("$", value: $discount, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("New Invoice")
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
        invoice.invoiceNumber = invoiceNumber
        invoice.clientID = selectedClient?.id
        invoice.issueDate = issueDate
        invoice.dueDate = dueDate
        invoice.status = Invoice.InvoiceStatus.draft.rawValue
        invoice.paymentTerms = paymentTerms
        invoice.notes = notes
        invoice.taxRate = taxRate
        invoice.discount = discount
        invoice.total = total
        invoice.subtotal = total + discount - (total * (taxRate / 100.0))
        invoice.taxAmount = total * (taxRate / 100.0)
        invoice.createdAt = Date()
        invoice.updatedAt = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving invoice: \(nsError)")
        }
    }
}