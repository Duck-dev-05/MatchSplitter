import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddGroup = false
    @State private var appear = false
    @State private var showLoginAlert = false
    @State private var fabPulse = false

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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: Hero Header
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                if let name = viewModel.currentUser?.name {
                                    Text("Hello, \(name.components(separatedBy: " ").first ?? "") 👋")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.white.opacity(0.6))
                                } else {
                                    Text("Welcome 👋")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Text("MatchSplitter")
                                    .font(.largeTitle.weight(.heavy))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                            if let name = viewModel.currentUser?.name {
                                GradientAvatar(name: name, size: 46)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 46))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                        // Net Balance Hero Card
                        heroBallanceCard
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
                                .buttonStyle(PressableButtonStyle())
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

    // MARK: - Hero Balance Card
    private var heroBallanceCard: some View {
        VStack(spacing: 16) {
            Text("YOUR NET BALANCE")
                .font(.caption.weight(.bold))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)

            Text(netBalance >= 0
                 ? "+\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", netBalance))"
                 : "-\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", abs(netBalance)))")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text(netBalance >= 0 ? "People owe you overall" : "You owe overall")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white.opacity(0.6))

            // Shimmer divider
            shimmerDivider

            HStack {
                StatBadge(
                    icon: "person.3.fill",
                    label: "Groups",
                    value: "\(totalGroups)",
                    color: Theme.secondaryAccent
                )
                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.2))
                StatBadge(
                    icon: "receipt.fill",
                    label: "Expenses",
                    value: "\(viewModel.groups.flatMap { $0.expenses }.count)",
                    color: Theme.secondaryAccent
                )
                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.2))
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

    // Subtle animated shimmer line
    @State private var shimmerOffset: CGFloat = -200

    private var shimmerDivider: some View {
        ZStack {
            Divider().background(Color.white.opacity(0.2))
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 1)
                    .fill(
                        LinearGradient(
                            colors: [.clear, Theme.secondaryAccent.opacity(0.6), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 80, height: 1)
                    .offset(x: shimmerOffset)
                    .onAppear {
                        withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                            shimmerOffset = geo.size.width + 80
                        }
                    }
            }
            .frame(height: 1)
        }
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

    var memberInitials: [String] {
        group.members.prefix(4).map { String($0.name.prefix(1)).uppercased() }
    }

    // Spending ratio for progress bar (capped at 1)
    var spendingRatio: Double {
        let maxBudget: Double = 1000
        return min(totalSpent / maxBudget, 1.0)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top gradient accent bar
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: 3)

            HStack(spacing: 14) {
                // Group icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accentColor.opacity(0.16))
                        .frame(width: 52, height: 52)
                    Image(systemName: "person.3.fill")
                        .foregroundColor(accentColor)
                        .font(.title3.weight(.semibold))
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(group.name)
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)

                        Text(isCreator ? "Creator" : "Member")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(isCreator ? Theme.secondaryAccent : .white.opacity(0.6))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(isCreator ? Theme.secondaryAccent.opacity(0.15) : Color.white.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    // Member avatar row
                    HStack(spacing: -8) {
                        ForEach(Array(memberInitials.enumerated()), id: \.offset) { _, initial in
                            ZStack {
                                Circle().fill(Theme.cardBackground).frame(width: 24, height: 24)
                                Circle().fill(accentColor.opacity(0.25)).frame(width: 22, height: 22)
                                Text(initial)
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(accentColor)
                            }
                        }
                        if group.members.count > 4 {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.10)).frame(width: 24, height: 24)
                                Text("+\(group.members.count - 4)")
                                    .font(.system(size: 8, weight: .bold)) // Keeping this tiny
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text(group.currency.symbol + String(format: "%.2f", totalSpent))
                        .font(.title3.weight(.heavy))
                        .foregroundColor(.white)
                    Text("\(group.expenses.count) expenses")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white.opacity(0.6))
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(18)

            // Spending progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 3)
                    Rectangle()
                        .fill(accentColor.opacity(0.70))
                        .frame(width: geo.size.width * CGFloat(spendingRatio), height: 3)
                }
            }
            .frame(height: 3)
        }
        .glassCard(cornerRadius: 20)
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
                .font(.title2.weight(.bold))
                .foregroundColor(.white.opacity(0.85))
            Text("Tap the + button to create\nyour first expense group.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
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

                            Divider().background(Color.white.opacity(0.2))

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
