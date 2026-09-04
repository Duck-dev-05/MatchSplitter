import SwiftUI
import CoreData

struct InvoicesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.isMember) private var isMember
    @FetchRequest private var invoices: FetchedResults<Invoice>
    @FetchRequest private var clients:  FetchedResults<Client>

    let groupID: UUID

    init(groupID: UUID) {
        self.groupID = groupID
        let predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        _invoices = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.createdAt, ascending: false)],
            predicate: predicate, animation: .default)
        _clients = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
            predicate: predicate, animation: .default)
    }

    @State private var showingAddInvoice = false
    @State private var selectedInvoice: Invoice?

    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()

                if invoices.isEmpty {
                    emptyStateView
                } else {
                    List {
                        if isMember {
                            ForEach(invoices) { invoice in
                                InvoiceRowView(invoice: invoice, clients: clients)
                                    .onTapGesture { selectedInvoice = invoice }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(
                                        top: Theme.spacingS, leading: Theme.spacingM,
                                        bottom: Theme.spacingS, trailing: Theme.spacingM
                                    ))
                            }
                        } else {
                            ForEach(invoices) { invoice in
                                InvoiceRowView(invoice: invoice, clients: clients)
                                    .onTapGesture { selectedInvoice = invoice }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(
                                        top: Theme.spacingS, leading: Theme.spacingM,
                                        bottom: Theme.spacingS, trailing: Theme.spacingM
                                    ))
                            }
                            .onDelete(perform: deleteInvoices)
                        }
                    }
                    .listStyle(.plain)
                    .padding(.top, Theme.spacingS)
                }
            }
            .navigationTitle("Splits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isMember {
                        Button(action: { showingAddInvoice = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Theme.primary)
                        }
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
        VStack(spacing: Theme.spacingL) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.10))
                    .frame(width: 110, height: 110)
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Theme.primary.opacity(0.55))
            }

            VStack(spacing: Theme.spacingS) {
                Text("No Splits Yet")
                    .font(Typography.headline())
                Text("Create a split to divide match costs with your team.")
                    .font(Typography.caption())
                    .foregroundColor(Theme.dynamicTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacingXL)
            }

            Button(action: { showingAddInvoice = true }) {
                Label("Create Split", systemImage: "plus.circle.fill")
                    .font(Typography.button())
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.spacingXL)
                    .padding(.vertical, Theme.spacingM)
                    .background(Theme.gradientPrimary)
                    .cornerRadius(Theme.radiusXL)
                    .shadow(color: Theme.primary.opacity(0.35), radius: 12, x: 0, y: 5)
            }
        }
        .padding()
    }

    private func deleteInvoices(offsets: IndexSet) {
        withAnimation {
            offsets.map { invoices[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting invoices: \(error)")
            }
        }
    }
}