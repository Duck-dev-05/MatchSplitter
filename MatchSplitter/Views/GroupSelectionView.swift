import SwiftUI
import CoreData

struct GroupSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var session: SessionManager
    
    @FetchRequest private var groups: FetchedResults<BusinessGroup>
    
    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    
    init(userID: UUID) {
        let request: NSFetchRequest<BusinessGroup> = BusinessGroup.fetchRequest()
        request.predicate = NSPredicate(format: "ownerID == %@", userID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BusinessGroup.name, ascending: true)]
        _groups = FetchRequest(fetchRequest: request, animation: .default)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()
                
                VStack(spacing: Theme.spacingL) {
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.spacingXS) {
                            Text("Welcome, \(session.currentUser?.username ?? "User")!")
                                .font(Typography.headline())
                            Text("Select a group or business to continue.")
                                .font(Typography.body())
                                .foregroundColor(Theme.dynamicTextSecondary)
                        }
                        Spacer()
                        Button("Log Out") {
                            session.logout()
                        }
                        .font(Typography.captionBold())
                        .foregroundColor(Theme.error)
                    }
                    .padding(.horizontal)
                    .padding(.top, Theme.spacingL)
                    
                    if groups.isEmpty {
                        VStack(spacing: Theme.spacingL) {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.primary)
                            Text("No groups found.")
                                .font(Typography.subheadline())
                            Text("Create your first group to start generating invoices.")
                                .font(Typography.body())
                                .foregroundColor(Theme.dynamicTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(Theme.spacingXL)
                        .cardStyle()
                        .padding(.top, Theme.spacingL)
                    } else {
                        ScrollView {
                            VStack(spacing: Theme.spacingM) {
                                ForEach(groups) { group in
                                    Button {
                                        session.selectGroup(group: group)
                                    } label: {
                                        HStack {
                                            Image(systemName: "building.2.crop.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(Theme.secondary)
                                            Text(group.name)
                                                .font(Typography.bodyBold())
                                                .foregroundColor(Theme.dynamicTextPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(Theme.dynamicTextSecondary.opacity(0.5))
                                        }
                                        .padding(Theme.spacingM)
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
                        .font(Typography.button())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.gradientPrimary)
                        .cornerRadius(Theme.radiusM)
                        .shadow(color: Theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, Theme.spacingL)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddGroup) {
                NavigationView {
                    ZStack {
                        Theme.dynamicBackground.ignoresSafeArea()
                        
                        VStack(spacing: Theme.spacingL) {
                            VStack(alignment: .leading, spacing: Theme.spacingS) {
                                Text("Group Name")
                                    .font(Typography.captionBold())
                                TextField("e.g. Acme Corp, Personal", text: $newGroupName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            .padding(Theme.spacingM)
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
            let newGroup = BusinessGroup(context: viewContext)
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
