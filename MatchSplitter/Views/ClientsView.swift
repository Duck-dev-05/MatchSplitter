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

    @State private var showingAddClient   = false
    @State private var isPresentingScanner = false
    @State private var selectedClient:     Client?

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
                                .onTapGesture { selectedClient = client }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(
                                    top: Theme.spacingS, leading: Theme.spacingM,
                                    bottom: Theme.spacingS, trailing: Theme.spacingM
                                ))
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
                    case .success(let code): handleScannedCode(code)
                    case .failure(let error): print("Scan failed: \(error.localizedDescription)")
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
        VStack(spacing: Theme.spacingL) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.10))
                    .frame(width: 110, height: 110)
                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Theme.primary.opacity(0.55))
            }

            VStack(spacing: Theme.spacingS) {
                Text("No Players Yet")
                    .font(Typography.headline())
                Text("Add your teammates to start splitting matches.")
                    .font(Typography.caption())
                    .foregroundColor(Theme.dynamicTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacingXL)
            }

            Button(action: { showingAddClient = true }) {
                Label("Add Player", systemImage: "person.badge.plus")
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

    private func deleteClients(offsets: IndexSet) {
        withAnimation {
            offsets.map { clients[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting client: \(error)")
            }
        }
    }

    private func handleScannedCode(_ code: String) {
        guard let data = code.data(using: .utf8) else { return }

        // Try decoding as Team Invite
        if let teamInvite = try? JSONDecoder().decode(TeamInviteData.self, from: data), teamInvite.type == "teamInvite" {
            let now = Date().timeIntervalSince1970
            if teamInvite.expiresAt > now {
                let newGroup = BusinessGroup(context: viewContext)
                newGroup.id = UUID(uuidString: teamInvite.groupID) ?? UUID()
                newGroup.name = teamInvite.groupName
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
            newClient.id        = UUID()
            newClient.groupID   = groupID
            newClient.name      = profile.name
            newClient.email     = profile.email
            newClient.phone     = ""
            newClient.address   = ""
            newClient.city      = ""
            newClient.state     = ""
            newClient.zipCode   = ""
            newClient.country   = ""
            newClient.taxID     = ""
            newClient.notes     = "Added via QR Code"
            newClient.createdAt = Date()
            newClient.updatedAt = Date()
            try viewContext.save()
        } catch {
            print("Failed to decode QR Profile: \(error)")
        }
    }
}

// MARK: - ClientRowView

struct ClientRowView: View {
    let client: Client

    // Deterministic gradient color per client
    private var avatarGradient: LinearGradient {
        let hue = Double(abs(client.name.hashValue) % 360) / 360.0
        return LinearGradient(
            colors: [
                Color(hue: hue, saturation: 0.65, brightness: 0.85),
                Color(hue: (hue + 0.08).truncatingRemainder(dividingBy: 1.0), saturation: 0.8, brightness: 0.65)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    var body: some View {
        HStack(spacing: Theme.spacingM) {
            // Gradient avatar
            ZStack {
                Circle()
                    .fill(avatarGradient)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                Text(String(client.name.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(client.name)
                    .font(Typography.bodyBold())
                    .foregroundColor(Theme.dynamicTextPrimary)
                if !client.email.isEmpty {
                    Text(client.email)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Theme.dynamicTextSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.dynamicTextSecondary.opacity(0.4))
        }
        .padding(.vertical, Theme.spacingS)
        .padding(.horizontal, Theme.spacingM)
        .background(Theme.dynamicCardBackground)
        .cornerRadius(Theme.radiusL)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}