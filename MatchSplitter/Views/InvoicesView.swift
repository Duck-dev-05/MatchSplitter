import SwiftUI
import CoreData

struct InvoicesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.createdAt, ascending: false)],
        animation: .default)
    private var invoices: FetchedResults<Invoice>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
        animation: .default)
    private var clients: FetchedResults<Client>
    
    @State private var showingAddInvoice = false
    @State private var selectedInvoice: Invoice?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(invoices) { invoice in
                    InvoiceRowView(invoice: invoice, clients: clients)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedInvoice = invoice
                        }
                }
                .onDelete(perform: deleteInvoices)
            }
            .navigationTitle("Invoices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddInvoice = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddInvoice) {
                AddInvoiceView()
            }
            .sheet(item: $selectedInvoice) { invoice in
                InvoiceDetailView(invoice: invoice)
            }
        }
    }
    
    private func deleteInvoices(offsets: IndexSet) {
        withAnimation {
            offsets.map { invoices[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting invoices: \(nsError)")
            }
        }
    }
}