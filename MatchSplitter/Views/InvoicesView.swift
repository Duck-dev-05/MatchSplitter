import SwiftUI
import CoreData

struct InvoicesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var invoices: FetchedResults<Invoice>
    @FetchRequest private var clients: FetchedResults<Client>
    
    let groupID: UUID
    
    init(groupID: UUID) {
        self.groupID = groupID
        let predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        
        _invoices = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.createdAt, ascending: false)],
            predicate: predicate,
            animation: .default)
            
        _clients = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
            predicate: predicate,
            animation: .default)
    }
    
    @State private var showingAddInvoice = false
    @State private var selectedInvoice: Invoice?
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if invoices.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(invoices) { invoice in
                            InvoiceRowView(invoice: invoice, clients: clients)
                                .onTapGesture {
                                    selectedInvoice = invoice
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete(perform: deleteInvoices)
                    }
                    .listStyle(.plain)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Invoices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddInvoice = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddInvoice) {
                AddInvoiceView(groupID: groupID)
            }
            .sheet(item: $selectedInvoice) { invoice in
                InvoiceDetailView(invoice: invoice)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(Theme.primary.opacity(0.5))
            Text("No Invoices Yet")
                .font(.system(.title3, design: .rounded).bold())
            Text("Create an invoice to bill your clients.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { showingAddInvoice = true }) {
                Text("Create Invoice")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Theme.gradientPrimary)
                    .cornerRadius(12)
                    .shadow(color: Theme.primary.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.top, 8)
        }
        .padding()
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