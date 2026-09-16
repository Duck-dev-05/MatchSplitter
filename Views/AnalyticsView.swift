import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.layoutMetrics) var metrics
    @State private var appear = false

    struct CategoryStat: Identifiable {
        let category: String
        let amount: Double
        let icon: String
        let color: Color
        var id: String { category }
    }

    var myGroups: [Group] {
        guard let user = viewModel.currentUser else { return [] }
        return viewModel.groups.filter { group in
            group.members.contains(where: { $0.id == user.id })
        }
    }

    var categoryData: [CategoryStat] {
        var totals: [ExpenseCategory: Double] = [:]
        for group in myGroups {
            for expense in group.expenses {
                totals[expense.category, default: 0.0] += expense.amount
            }
        }
        return totals.map { key, val in
            let color: Color
            switch key {
            case .food:          color = Theme.warmGold
            case .transport:     color = Theme.secondaryAccent
            case .rent:          color = Theme.primaryAccent
            case .entertainment: color = Theme.dangerColor
            case .travel:        color = Theme.successColor
            case .general:       color = Color.white.opacity(0.5)
            }
            return CategoryStat(category: key.rawValue, amount: val, icon: key.iconName, color: color)
        }
        .sorted { $0.amount > $1.amount }
    }

    var totalSpent: Double {
        myGroups.flatMap { $0.expenses.map { $0.amount } }.reduce(0, +)
    }

    var overallBalance: Double {
        SettlementService.shared.calculateGlobalBalances(currentUser: viewModel.currentUser, groups: myGroups).values.flatMap { $0.values }.reduce(0, +)
    }

    var totalOwed: Double {
        SettlementService.shared.calculateGlobalBalances(currentUser: viewModel.currentUser, groups: myGroups).values.flatMap { $0.values }.filter { $0 < 0 }.reduce(0, +)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                AmbientGlob(color: Theme.primaryAccent, size: 280, blurRadius: 90, opacity: 0.09, offsetX: -80, offsetY: 40)
                    .ignoresSafeArea()
                AmbientGlob(color: Theme.secondaryAccent, size: 200, blurRadius: 80, opacity: 0.06, offsetX: 120, offsetY: 400)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // MARK: Page Header
                        PageHeader(
                            title: "Analytics",
                            subtitle: "Spending breakdown across groups"
                        )

                        // MARK: Stats Row — 3 individual cards
                        HStack(spacing: 10) {
                            HeroMetricCard(
                                icon: "banknote.fill",
                                label: "Total Spent",
                                value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.0f", totalSpent))",
                                color: Theme.secondaryAccent,
                                valueFont: metrics.adaptive(20, 24, 28)
                            )
                            HeroMetricCard(
                                icon: "arrow.down.circle.fill",
                                label: "Owed to You",
                                value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.0f", overallBalance > 0 ? overallBalance : 0))",
                                color: Theme.successColor,
                                valueFont: metrics.adaptive(20, 24, 28)
                            )
                            HeroMetricCard(
                                icon: "arrow.up.circle.fill",
                                label: "You Owe",
                                value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.0f", abs(totalOwed)))",
                                color: Theme.dangerColor,
                                valueFont: metrics.adaptive(20, 24, 28)
                            )
                        }
                        .padding(.horizontal, 20)

                        // MARK: Chart
                        if categoryData.isEmpty {
                            EmptyStateView(
                                icon: "📊",
                                title: "No Spending Data Yet",
                                subtitle: "Add expenses to your groups and your breakdown will appear here."
                            )
                            .padding(.top, 10)
                        } else {
                            if #available(iOS 16.0, *) {
                                iOS16ChartView(categoryData: categoryData)
                            } else {
                                iOS15ChartView(categoryData: categoryData, appear: appear)
                            }
                        }
                        
                        // MARK: Budgets
                        let budgetedGroups = myGroups.filter { $0.budgetLimit != nil }
                        if !budgetedGroups.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Group Budgets")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                
                                ForEach(budgetedGroups) { group in
                                    let budget = group.budgetLimit ?? 0
                                    let spent = group.expenses.map { $0.amount }.reduce(0, +)
                                    let percentage = budget > 0 ? min(spent / budget, 1.0) : (spent > 0 ? 1.0 : 0.0)
                                    let isOver = spent > budget
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(group.name)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text("\(group.currency.symbol)\(String(format: "%.0f", spent)) / \(group.currency.symbol)\(String(format: "%.0f", budget))")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(isOver ? Theme.dangerColor : .white.opacity(0.6))
                                        }
                                        
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.white.opacity(0.1))
                                                    .frame(height: 8)
                                                
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(isOver ? Theme.dangerColor : Theme.primaryAccent)
                                                    .frame(width: geo.size.width * CGFloat(percentage), height: 8)
                                            }
                                        }
                                        .frame(height: 8)
                                    }
                                    .padding(16)
                                    .glassCard(cornerRadius: 16)
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .navigationBarHidden(true)
            .onAppear { withAnimation(.easeOut(duration: 0.6)) { appear = true } }
        }
    }

    // analyticsStatCard replaced by HeroMetricCard (defined in Theme.swift)
}

// MARK: - iOS 15 Custom Chart
struct iOS15ChartView: View {
    let categoryData: [AnalyticsView.CategoryStat]
    var appear: Bool

    var totalAmount: Double { categoryData.map { $0.amount }.reduce(0, +) }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Spending by Category")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(categoryData.count) categories")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.40))
            }

            let maxAmount = categoryData.map { $0.amount }.max() ?? 1.0

            VStack(spacing: 14) {
                ForEach(Array(categoryData.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 12) {
                        IconBadge(systemName: item.icon, color: item.color, size: 36, iconSize: 13)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(item.category)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.85))
                                Spacer()
                                HStack(spacing: 6) {
                                    Text(String(format: "%.0f", item.amount))
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    // Percentage chip
                                    Text(String(format: "%.0f%%", (item.amount / totalAmount) * 100))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(item.color)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(item.color.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.06))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 10)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(LinearGradient(
                                            colors: [item.color, item.color.opacity(0.55)],
                                            startPoint: .leading, endPoint: .trailing
                                        ))
                                        .frame(
                                            width: appear
                                                ? max(CGFloat(item.amount / maxAmount) * geo.size.width, 10)
                                                : 0,
                                            height: 10
                                        )
                                        .animation(
                                            .spring(response: 0.65, dampingFraction: 0.78)
                                            .delay(Double(index) * 0.08),
                                            value: appear
                                        )
                                }
                            }
                            .frame(height: 10)
                        }
                    }
                }
            }
        }
        .padding(22)
        .glassCard(cornerRadius: 24)
        .padding(.horizontal, 20)
    }
}

// MARK: - iOS 16+ Chart
@available(iOS 16.0, *)
struct iOS16ChartView: View {
    let categoryData: [AnalyticsView.CategoryStat]

    var body: some View {
        #if canImport(Charts)
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Spending by Category")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(categoryData.count) categories")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.40))
            }

            Chart {
                ForEach(categoryData, id: \.category) { item in
                    BarMark(
                        x: .value("Amount", item.amount),
                        y: .value("Category", item.category)
                    )
                    .foregroundStyle(Theme.primaryGradient)
                    .cornerRadius(8)
                }
            }
            .frame(height: CGFloat(categoryData.count) * 50 + 20)
            .chartXAxis {
                AxisMarks(values: .automatic) {
                    AxisValueLabel().foregroundStyle(Color.white.opacity(0.40))
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.06))
                }
            }
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel()
                        .foregroundStyle(Color.white.opacity(0.80))
                        .font(.system(size: 12, weight: .medium))
                }
            }
        }
        .padding(22)
        .glassCard(cornerRadius: 24)
        .padding(.horizontal, 20)
        #else
        EmptyView()
        #endif
    }
}
