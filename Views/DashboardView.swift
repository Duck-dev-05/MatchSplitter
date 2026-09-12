import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddGroup = false
    @State private var appear = false
    @State private var showLoginAlert = false

    var totalGroups: Int { viewModel.groups.count }

    var netBalance: Double {
        let balances = viewModel.calculateGlobalBalances()
        return balances.values.flatMap { $0.values }.reduce(0, +)
    }

    @ViewBuilder
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack { dashboardContent }
        } else {
            NavigationView { dashboardContent }
        }
    }

    var dashboardContent: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            // Ambient glow blobs
            AmbientGlob(color: Theme.primaryAccent, size: 300, blurRadius: 100, opacity: 0.10, offsetX: -80, offsetY: -60)
                .ignoresSafeArea()
            AmbientGlob(color: Theme.secondaryAccent, size: 200, blurRadius: 80, opacity: 0.07, offsetX: 120, offsetY: 200)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: Hero Header
                    heroHeader
                        .padding(.bottom, 6)

                    // MARK: Hero Balance Card
                    heroBallanceCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)

                    // MARK: Groups Section
                    SectionHeader(title: "Your Groups", trailing: AnyView(
                        Text("\(viewModel.groups.count)")
                            .font(.caption.weight(.bold))
                            .foregroundColor(Theme.secondaryAccent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.secondaryAccent.opacity(0.14))
                            .clipShape(Capsule())
                    ))
                    .padding(.bottom, 14)

                    VStack(spacing: 14) {
                        if viewModel.groups.isEmpty {
                            EmptyGroupsView()
                                .padding(.top, 40)
                        } else {
                            ForEach(viewModel.groups.indexed) { indexed in
                                NavigationLink(destination: GroupDetailView(group: indexed.item)) {
                                    GroupCardView(group: indexed.item)
                                }
                                .buttonStyle(PressableButtonStyle())
                                .offset(y: appear ? 0 : 30)
                                .opacity(appear ? 1 : 0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.78)
                                    .delay(Double(indexed.index) * 0.07),
                                    value: appear
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if viewModel.currentUser == nil {
                        showLoginAlert = true
                    } else {
                        showingAddGroup = true
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.secondaryAccent)
                }
            }
        }
        .sheet(isPresented: $showingAddGroup) {
            AddGroupSheet()
        }
        .alert("Account Required", isPresented: $showLoginAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please go to the Profile tab to Login or Register before creating groups.")
        }
        .onAppear {
            withAnimation { appear = true }
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                if let name = viewModel.currentUser?.name {
                    Text("Hello, \(name.components(separatedBy: " ").first ?? "") 👋")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.55))
                } else {
                    Text("Welcome 👋")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.55))
                }
                Text("MatchSplitter")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            if let name = viewModel.currentUser?.name {
                GradientAvatar(name: name, avatarURL: viewModel.currentUser?.avatarURL, size: 44)
                    .overlay(
                        Circle()
                            .stroke(Theme.primaryGradient, lineWidth: 2)
                    )
            } else {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.35))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Hero Balance Card
    private var heroBallanceCard: some View {
        VStack(spacing: 18) {
            // Balance label
            Text("YOUR NET BALANCE")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .kerning(1.5)

            Text(netBalance >= 0
                 ? "+\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", netBalance))"
                 : "-\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", abs(netBalance)))")
                .font(.system(size: 46, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            // Status pill
            HStack(spacing: 6) {
                Circle()
                    .fill(netBalance >= 0 ? Theme.successColor : Theme.dangerColor)
                    .frame(width: 7, height: 7)
                Text(netBalance >= 0 ? "People owe you overall" : "You owe overall")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(netBalance >= 0 ? Theme.successColor : Theme.dangerColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background((netBalance >= 0 ? Theme.successColor : Theme.dangerColor).opacity(0.12))
            .clipShape(Capsule())

            Divider().background(Color.white.opacity(0.10))

            HStack(spacing: 0) {
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
                    color: Theme.primaryAccent
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
        .accentCard(cornerRadius: 28)
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
            Theme.warmGold,
        ]
        return colors[abs(group.name.hashValue) % colors.count]
    }

    var spendingRatio: Double {
        let maxBudget: Double = 1000
        return min(totalSpent / maxBudget, 1.0)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)
                .padding(.vertical, 14)
                .padding(.leading, 14)

            HStack(spacing: 14) {
                // Group icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accentColor.opacity(0.14))
                        .frame(width: 50, height: 50)
                    Image(systemName: "person.3.fill")
                        .foregroundColor(accentColor)
                        .font(.system(size: 18, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(group.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text(isCreator ? "Creator" : "Member")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isCreator ? Theme.secondaryAccent : .white.opacity(0.5))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(isCreator ? Theme.secondaryAccent.opacity(0.14) : Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }

                    // Member avatars row
                    HStack(spacing: -10) {
                        ForEach(Array(group.members.prefix(4)).indexed) { indexed in
                            GradientAvatar(
                                name: indexed.item.name,
                                avatarURL: indexed.item.avatarURL,
                                size: 24,
                                gradient: LinearGradient(
                                    colors: [accentColor, accentColor.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(Circle().stroke(Theme.cardBackground, lineWidth: 1.5))
                        }
                        if group.members.count > 4 {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.10))
                                    .frame(width: 24, height: 24)
                                    .overlay(Circle().stroke(Theme.cardBackground, lineWidth: 1.5))
                                Text("+\(group.members.count - 4)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(group.currency.symbol + String(format: "%.2f", totalSpent))
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("\(group.expenses.count) expenses")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white.opacity(0.5))

                    // Spending bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.07))
                                .frame(height: 4)
                            Capsule()
                                .fill(accentColor.opacity(0.80))
                                .frame(width: geo.size.width * CGFloat(spendingRatio), height: 4)
                        }
                    }
                    .frame(width: 70, height: 4)
                }
                .padding(.trailing, 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.25))
                    .padding(.trailing, 4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
        }
        .glassCard(cornerRadius: 20)
    }
}

// MARK: - Empty State
struct EmptyGroupsView: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.06))
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulse ? 1.15 : 1.0)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulse)
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.10))
                    .frame(width: 90, height: 90)
                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 38))
                    .foregroundColor(Theme.primaryAccent.opacity(0.5))
            }
            .padding(.bottom, 4)

            Text("No Groups Yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            Text("Tap the + button to create\nyour first expense group.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center)
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Add Group Sheet
struct AddGroupSheet: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var groupName: String = ""
    @State private var selectedCurrency: Currency = .usd

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                DragHandle()
                    .padding(.bottom, 4)

                SheetHeader(
                    title: "New Group",
                    trailingLabel: "Create",
                    trailingEnabled: !groupName.isEmpty,
                    onLeading: { presentationMode.wrappedValue.dismiss() },
                    onTrailing: {
                        if !groupName.isEmpty {
                            viewModel.addGroup(name: groupName, currency: selectedCurrency)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 0) {
                            HStack(spacing: 14) {
                                IconBadge(systemName: "person.3.fill", color: Theme.primaryAccent)
                                TextField("Group Name", text: $groupName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)

                            Divider().background(Color.white.opacity(0.1))

                            HStack(spacing: 14) {
                                IconBadge(systemName: "banknote.fill", color: Theme.warmGold)
                                Menu {
                                    ForEach(Currency.allCases, id: \.self) { c in
                                        Button("\(c.rawValue) (\(c.symbol))") { selectedCurrency = c }
                                    }
                                } label: {
                                    HStack {
                                        Text("\(selectedCurrency.rawValue) (\(selectedCurrency.symbol))")
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                        }
                        .glassCard(cornerRadius: 22)
                    }
                    .padding(20)
                }
            }
        }
        .onAppear {
            selectedCurrency = viewModel.defaultCurrency
        }
    }
}
