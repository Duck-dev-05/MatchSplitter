import SwiftUI
import CoreData

struct GroupSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var session: SessionManager

    @FetchRequest private var groups: FetchedResults<BusinessGroup>

    @State private var showingAddGroup = false
    @State private var newGroupName    = ""

    init(userID: UUID) {
        let request: NSFetchRequest<BusinessGroup> = BusinessGroup.fetchRequest()
        request.predicate = NSPredicate(format: "ownerID == %@", userID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BusinessGroup.name, ascending: true)]
        _groups = FetchRequest(fetchRequest: request, animation: .default)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Subtle gradient backdrop
                LinearGradient(
                    colors: [Theme.primary.opacity(0.08), Theme.dynamicBackground],
                    startPoint: .top, endPoint: .center
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {

                    // ── Header ──
                    VStack(spacing: Theme.spacingXS) {
                        ZStack {
                            Circle()
                                .fill(Theme.gradientPrimary)
                                .frame(width: 72, height: 72)
                                .shadow(color: Theme.primary.opacity(0.4), radius: 14, x: 0, y: 6)
                            Image(systemName: "sportscourt.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("Welcome back,")
                            .font(Typography.caption())
                            .foregroundColor(Theme.dynamicTextSecondary)
                        Text(session.currentUser?.username ?? "Player")
                            .font(Typography.largeTitle())
                            .foregroundColor(Theme.dynamicTextPrimary)

                        Text("Pick a team to continue")
                            .font(Typography.caption())
                            .foregroundColor(Theme.dynamicTextSecondary)
                    }
                    .padding(.top, Theme.spacingXXL)
                    .padding(.bottom, Theme.spacingXL)

                    // ── Team List ──
                    if groups.isEmpty {
                        Spacer()
                        VStack(spacing: Theme.spacingM) {
                            Image(systemName: "person.3.sequence.fill")
                                .font(.system(size: 52))
                                .foregroundColor(Theme.primary.opacity(0.4))
                            Text("No teams yet")
                                .font(Typography.subheadlineBold())
                            Text("Create your first team to get started.")
                                .font(Typography.caption())
                                .foregroundColor(Theme.dynamicTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(Theme.spacingXL)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: Theme.spacingM) {
                                ForEach(groups) { group in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            session.selectGroup(group: group)
                                        }
                                    } label: {
                                        HStack(spacing: Theme.spacingM) {
                                            // Gradient icon circle
                                            ZStack {
                                                Circle()
                                                    .fill(Theme.gradientPrimary)
                                                    .frame(width: 52, height: 52)
                                                Text(String(group.name.prefix(1)).uppercased())
                                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                                    .foregroundColor(.white)
                                            }

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(group.name)
                                                    .font(Typography.bodyBold())
                                                    .foregroundColor(Theme.dynamicTextPrimary)
                                                Text("Since \(group.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                                    .font(.system(size: 12, design: .rounded))
                                                    .foregroundColor(Theme.dynamicTextSecondary)
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(Theme.primary.opacity(0.6))
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

                    // ── Bottom Actions ──
                    VStack(spacing: Theme.spacingM) {
                        Button {
                            showingAddGroup = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Create New Team")
                            }
                            .font(Typography.button())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.gradientPrimary)
                            .cornerRadius(Theme.radiusXL)
                            .shadow(color: Theme.primary.opacity(0.35), radius: 12, x: 0, y: 5)
                        }

                        Button {
                            session.logout()
                        } label: {
                            Text("Log Out")
                                .font(Typography.captionBold())
                                .foregroundColor(Theme.error)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, Theme.spacingXL)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddGroup) {
                NavigationView {
                    ZStack {
                        Theme.dynamicBackground.ignoresSafeArea()
                        VStack(spacing: Theme.spacingL) {
                            VStack(alignment: .leading, spacing: Theme.spacingS) {
                                Text("Team Name")
                                    .font(Typography.captionBold())
                                    .foregroundColor(Theme.dynamicTextSecondary)
                                TextField("e.g. Friday Warriors, My Squad", text: $newGroupName)
                                    .font(Typography.body())
                                    .padding(Theme.spacingM)
                                    .background(Theme.dynamicCardBackground)
                                    .cornerRadius(Theme.radiusM)
                            }
                            .padding(Theme.spacingM)
                            .cardStyle()
                            .padding()
                            Spacer()
                        }
                    }
                    .navigationTitle("New Team")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") { showingAddGroup = false }
                                .foregroundColor(Theme.dynamicTextSecondary)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Create") {
                                createGroup()
                                showingAddGroup = false
                            }
                            .font(Typography.bodyBold())
                            .foregroundColor(Theme.primary)
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
