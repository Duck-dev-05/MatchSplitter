import SwiftUI
import CoreData

struct ClientsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
        animation: .default)
    private var clients: FetchedResults<Client>
    
    @State private var showingAddClient = false
    @State private var selectedClient: Client?
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
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
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete(perform: deleteClients)
                    }
                    .listStyle(.plain)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Clients")
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
                AddClientView()
            }
            .sheet(item: $selectedClient) { client in
                ClientDetailView(client: client)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 48))
                .foregroundColor(Theme.primary.opacity(0.5))
            Text("No Clients Yet")
                .font(.system(.title3, design: .rounded).bold())
            Text("Add your first client to get started.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { showingAddClient = true }) {
                Text("Add Client")
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
    
    private func deleteClients(offsets: IndexSet) {
        withAnimation {
            offsets.map { clients[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ClientRowView: View {
    let client: Client
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Theme.primary.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(client.name.prefix(1)).uppercased())
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundColor(Theme.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(client.name)
                    .font(.system(.headline, design: .rounded).bold())
                if !client.email.isEmpty {
                    Text(client.email)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.5))
                .font(.caption.bold())
        }
        .padding(16)
        .cardStyle()
    }
}