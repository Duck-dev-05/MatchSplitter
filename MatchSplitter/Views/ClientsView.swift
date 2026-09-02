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
            List {
                ForEach(clients) { client in
                    ClientRowView(client: client)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedClient = client
                        }
                }
                .onDelete(perform: deleteClients)
            }
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddClient = true }) {
                        Image(systemName: "plus")
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
        HStack {
            VStack(alignment: .leading) {
                Text(client.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !client.email.isEmpty {
                    Text(client.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}