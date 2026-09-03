import SwiftUI
import CoreData

struct GroupSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var session: SessionManager
    
    @FetchRequest private var groups: FetchedResults<Group>
    
    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    
    init(userID: UUID) {
        let request: NSFetchRequest<Group> = Group.fetchRequest()
        request.predicate = NSPredicate(format: "ownerID == %@", userID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Group.name, ascending: true)]
        _groups = FetchRequest(fetchRequest: request, animation: .default)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome, \(session.currentUser?.username ?? "User")!")
                                .font(.system(.title2, design: .rounded).bold())
                            Text("Select a group or business to continue.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Log Out") {
                            session.logout()
                        }
                        .font(.system(.subheadline, design: .rounded).bold())
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    if groups.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.primary)
                            Text("No groups found.")
                                .font(.headline)
                            Text("Create your first group to start generating invoices.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                        .cardStyle()
                        .padding(.top, 20)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(groups) { group in
                                    Button {
                                        session.selectGroup(group: group)
                                    } label: {
                                        HStack {
                                            Image(systemName: "building.2.crop.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(Theme.secondary)
                                            Text(group.name)
                                                .font(.system(.headline, design: .rounded))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary.opacity(0.5))
                                        }
                                        .padding(16)
                                        .cardStyle()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        showingAddGroup = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New Group")
                        }
                        .font(.system(.headline, design: .rounded).bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.gradientPrimary)
                        .cornerRadius(12)
                        .shadow(color: Theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddGroup) {
                NavigationView {
                    ZStack {
                        Theme.background.ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Group Name")
                                    .font(.system(.subheadline, design: .rounded).bold())
                                TextField("e.g. Acme Corp, Personal", text: $newGroupName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            .padding(16)
                            .cardStyle()
                            .padding()
                            
                            Spacer()
                        }
                    }
                    .navigationTitle("New Group")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") { showingAddGroup = false }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Create") {
                                createGroup()
                                showingAddGroup = false
                            }
                            .disabled(newGroupName.isEmpty)
                        }
                    }
                }
            }
        }
    }
    
    private func createGroup() {
        guard let userID = session.currentUser?.id else { return }
        
        withAnimation {
            let newGroup = Group(context: viewContext)
            newGroup.id = UUID()
            newGroup.name = newGroupName
            newGroup.ownerID = userID
            newGroup.createdAt = Date()
            
            do {
                try viewContext.save()
                session.selectGroup(group: newGroup)
            } catch {
                print("Error creating group: \(error)")
            }
        }
    }
}
