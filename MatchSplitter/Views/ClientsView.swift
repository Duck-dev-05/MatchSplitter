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
    @State private var isPresentingScanner = false
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
                    HStack(spacing: 16) {
                        Button(action: { isPresentingScanner = true }) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.title2)
                                .foregroundColor(Theme.primary)
                        }
                        Button(action: { showingAddClient = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Theme.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView(groupID: groupID)
            }
            .sheet(isPresented: $isPresentingScanner) {
                QRCodeScannerView { result in
                    isPresentingScanner = false
                    switch result {
                    case .success(let code):
                        handleScannedCode(code)
                    case .failure(let error):
                        print("Scanning failed: \(error.localizedDescription)")
                    }
                }
                .ignoresSafeArea()
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
                    .background(Theme.primary)
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
    
    private func handleScannedCode(_ code: String) {
        guard let data = code.data(using: .utf8) else { return }
        
        // Try decoding as Team Invite
        if let teamInvite = try? JSONDecoder().decode(TeamInviteData.self, from: data), teamInvite.type == "teamInvite" {
            let now = Date().timeIntervalSince1970
            if teamInvite.expiresAt > now {
                // Join team locally
                let newGroup = BusinessGroup(context: viewContext)
                newGroup.id = UUID(uuidString: teamInvite.groupID) ?? UUID()
                newGroup.name = teamInvite.groupName
                // Assuming local ownership for now so it appears in their list
                if let uid = UserDefaults.standard.string(forKey: "currentUserID") {
                    newGroup.ownerID = UUID(uuidString: uid) ?? UUID()
                } else {
                    newGroup.ownerID = UUID()
                }
                newGroup.createdAt = Date()
                
                try? viewContext.save()
            } else {
                print("Invite code expired")
            }
            return
        }
        
        // Otherwise treat as Player Profile QR
        do {
            let profile = try JSONDecoder().decode(QRProfileData.self, from: data)
            
            let newClient = Client(context: viewContext)
            newClient.id = UUID()
            newClient.groupID = groupID
            newClient.name = profile.name
            newClient.email = profile.email
            newClient.phone = ""
            newClient.address = ""
            newClient.city = ""
            newClient.state = ""
            newClient.zipCode = ""
            newClient.country = ""
            newClient.taxID = ""
            newClient.notes = "Added via QR Code"
            newClient.createdAt = Date()
            newClient.updatedAt = Date()
            
            try viewContext.save()
        } catch {
            print("Failed to decode QR Profile: \(error)")
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
        .padding(.vertical, Theme.spacingS)
        .padding(.horizontal, Theme.spacingM)
        .background(Theme.dynamicCardBackground)
        .cornerRadius(Theme.radiusM)
    }
}