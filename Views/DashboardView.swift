import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    @State private var appear = false

    var totalGroups: Int { viewModel.groups.count }

    var netBalance: Double {
        let balances = viewModel.calculateGlobalBalances()
        return balances.values.flatMap { $0.values }.reduce(0, +)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                // Background glow blobs
                GeometryReader { geo in
                    Circle()
                        .fill(Theme.primaryAccent.opacity(0.10))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .offset(x: geo.size.width * 0.5, y: -60)
                    Circle()
                        .fill(Theme.secondaryAccent.opacity(0.07))
                        .frame(width: 250, height: 250)
                        .blur(radius: 80)
                        .offset(x: -40, y: geo.size.height * 0.5)
                }
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // MARK: Hero Header
                        VStack(spacing: 0) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Hello, \(viewModel.currentUser?.name.components(separatedBy: " ").first ?? "there") 👋")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.55))
                                    Text("MatchSplitter")
                                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                GradientAvatar(name: viewModel.currentUser?.name ?? "Y", size: 46)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 20)

                            // Net Balance Hero Card
                            Theme.applyAccentCard(
                                to: AnyView(
                                    VStack(spacing: 16) {
                                        Text("YOUR NET BALANCE")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white.opacity(0.55))
                                            .textCase(.uppercase)

                                        Text(netBalance >= 0
                                             ? "+\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", netBalance))"
                                             : "-\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", abs(netBalance)))")
                                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                                            .foregroundColor(.white)

                                        Text(netBalance >= 0 ? "People owe you overall" : "You owe overall")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white.opacity(0.55))

                                        Divider().background(Color.white.opacity(0.12))

                                        HStack {
                                            StatBadge(
                                                icon: "person.3.fill",
                                                label: "Groups",
                                                value: "\(totalGroups)",
                                                color: Theme.secondaryAccent
                                            )
                                            Divider()
                                                .frame(height: 40)
                                                .background(Color.white.opacity(0.10))
                                            StatBadge(
                                                icon: "receipt.fill",
                                                label: "Expenses",
                                                value: "\(viewModel.groups.flatMap { $0.expenses }.count)",
                                                color: Theme.secondaryAccent
                                            )
                                            Divider()
                                                .frame(height: 40)
                                                .background(Color.white.opacity(0.10))
                                            StatBadge(
                                                icon: netBalance >= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                                                label: netBalance >= 0 ? "Owed to You" : "You Owe",
                                                value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.0f", abs(netBalance)))",
                                                color: netBalance >= 0 ? Theme.successColor : Theme.dangerColor
                                            )
                                        }
                                    }
                                    .padding(24)
                                    .frame(maxWidth: .infinity)
                                ),
                                cornerRadius: 28
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 28)
                        }

                        // MARK: Groups Section
                        SectionHeader(title: "Your Groups")
                            .padding(.bottom, 14)

                        VStack(spacing: 14) {
                            if viewModel.groups.isEmpty {
                                EmptyGroupsView()
                                    .padding(.top, 40)
                            } else {
                                ForEach(Array(viewModel.groups.enumerated()), id: \.element.id) { (index, group) in
                                    NavigationLink(destination: GroupDetailView(group: group)) {
                                        GroupCardView(group: group)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .offset(y: appear ? 0 : 30)
                                    .opacity(appear ? 1 : 0)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.78)
                                        .delay(Double(index) * 0.07),
                                        value: appear
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                    }
                }

                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddGroup = true }) {
                            ZStack {
                                Circle()
                                    .fill(Theme.primaryGradient)
                                    .frame(width: 62, height: 62)
                                    .shadow(color: Theme.primaryAccent.opacity(0.55), radius: 18, x: 0, y: 8)
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("New Group", isPresented: $showingAddGroup) {
                TextField("Group Name", text: $newGroupName)
                Button("Create") {
                    if !newGroupName.isEmpty {
                        withAnimation(.spring()) {
                            viewModel.addGroup(name: newGroupName)
                            newGroupName = ""
                        }
                    }
                }
                Button("Cancel", role: .cancel) { newGroupName = "" }
            }
        }
        .onAppear { withAnimation { appear = true } }
    }
}

// MARK: - Group Card
struct GroupCardView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel

    var totalSpent: Double { group.expenses.reduce(0) { $0 + $1.amount } }

    var isCreator: Bool { group.creatorID == viewModel.currentUser?.id }

    var accentColor: Color {
        let colors: [Color] = [
            Theme.primaryAccent,
            Theme.secondaryAccent,
            Theme.dangerColor,
            Theme.successColor,
            Color(red: 1.0, green: 0.65, blue: 0.15)
        ]
        return colors[abs(group.name.hashValue) % colors.count]
    }

    var memberInitials: [String] {
        group.members.prefix(4).map { String($0.name.prefix(1)).uppercased() }
    }

    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                VStack(spacing: 0) {
                    // Color accent bar
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [accentColor, accentColor.opacity(0.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 3)
                    }

                    HStack(spacing: 14) {
                        // Group icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(accentColor.opacity(0.16))
                                .frame(width: 52, height: 52)
                            Image(systemName: "person.3.fill")
                                .foregroundColor(accentColor)
                                .font(.system(size: 20, weight: .semibold))
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(group.name)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text(isCreator ? "Creator" : "Member")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(isCreator ? Theme.secondaryAccent : .white.opacity(0.4))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(isCreator ? Theme.secondaryAccent.opacity(0.15) : Color.white.opacity(0.1))
                                    .clipShape(Capsule())
                            }

                            // Member avatars row
                            HStack(spacing: -8) {
                                ForEach(Array(memberInitials.enumerated()), id: \.offset) { i, initial in
                                    ZStack {
                                        Circle()
                                            .fill(Theme.cardBackground)
                                            .frame(width: 24, height: 24)
                                        Circle()
                                            .fill(accentColor.opacity(0.25))
                                            .frame(width: 22, height: 22)
                                        Text(initial)
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(accentColor)
                                    }
                                }
                                if group.members.count > 4 {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.10))
                                            .frame(width: 24, height: 24)
                                        Text("+\(group.members.count - 4)")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 5) {
                            Text(group.currency.symbol + String(format: "%.2f", totalSpent))
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(group.expenses.count) expenses")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.40))
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.20))
                    }
                    .padding(18)
                }
            ),
            cornerRadius: 20
        )
    }
}

// MARK: - Empty State
struct EmptyGroupsView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.08))
                    .frame(width: 110, height: 110)
                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 46))
                    .foregroundColor(Theme.primaryAccent.opacity(0.4))
            }
            .padding(.bottom, 8)

            Text("No Groups Yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            Text("Tap the + button to create\nyour first expense group.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.40))
                .multilineTextAlignment(.center)
        }
    }
}
