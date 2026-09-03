import SwiftUI
import CoreData

struct ClientsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var clients: FetchedResults<Client>
    
    let groupID: UUID
    
    init(groupID: UUID) {
        self.groupID = groupID
        _clients = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
            predicate: NSPredicate(format: "groupID == %@", groupID as CVarArg),
            animation: .default)
    }
    
    @State private var showingAddClient = false
    @State private var selectedClient: Client?
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()
                
                if clients.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(clients) { client in
                            ClientRowView(client: client)
                                .onTapGesture {
                                    selectedClient = client
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: Theme.spacingS, leading: Theme.spacingM, bottom: Theme.spacingS, trailing: Theme.spacingM))
                        }
                        .onDelete(perform: deleteClients)
                    }
                    .listStyle(.plain)
                    .padding(.top, Theme.spacingS)
                }
            }
            .navigationTitle("Players")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddClient = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView(groupID: groupID)
            }
            .sheet(item: $selectedClient) { client in
                ClientDetailView(client: client)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.spacingM) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 48))
                .foregroundColor(Theme.primary.opacity(0.5))
            Text("No Players Yet")
                .font(Typography.subheadline())
            Text("Add your teammates to start splitting matches.")
                .font(Typography.body())
                .foregroundColor(Theme.dynamicTextSecondary)
            
            Button(action: { showingAddClient = true }) {
                Text("Add Player")
                    .font(Typography.button())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Theme.gradientPrimary)
                    .cornerRadius(Theme.radiusM)
                    .shadow(color: Theme.primary.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.top, Theme.spacingS)
        }
        .padding()
    }
    
    private func deleteClients(offsets: IndexSet) {
        withAnimation {
            offsets.map { clients[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting client: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ClientRowView: View {
    let client: Client
    
    var body: some View {
        HStack(spacing: Theme.spacingM) {
            Circle()
                .fill(Theme.primary.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(client.name.prefix(1)).uppercased())
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundColor(Theme.primary)
                )
            
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(client.name)
                    .font(Typography.bodyBold())
                if !client.email.isEmpty {
                    Text(client.email)
                        .font(Typography.caption())
                        .foregroundColor(Theme.dynamicTextSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.dynamicTextSecondary.opacity(0.5))
                .font(.caption.bold())
        }
        .padding(Theme.spacingM)
        .cardStyle()
    }
}