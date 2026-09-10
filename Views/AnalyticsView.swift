import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var appear = false

    var categoryData: [(category: String, amount: Double, icon: String, color: Color)] {
        var totals: [ExpenseCategory: Double] = [:]
        for group in viewModel.groups {
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
            return (category: key.rawValue, amount: val, icon: key.iconName, color: color)
        }
        .sorted { $0.amount > $1.amount }
    }

    var totalSpent: Double {
        viewModel.groups.flatMap { $0.expenses.map { $0.amount } }.reduce(0, +)
    }

    var overallBalance: Double {
        viewModel.calculateGlobalBalances().values.flatMap { $0.values }.reduce(0, +)
    }

    var totalOwed: Double {
        viewModel.calculateGlobalBalances().values.flatMap { $0.values }.filter { $0 < 0 }.reduce(0, +)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                Circle()
                    .fill(Theme.primaryAccent.opacity(0.09))
                    .frame(width: 260, height: 260)
                    .blur(radius: 80)
                    .offset(x: -80, y: 40)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // MARK: Page Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Analytics")
                                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Spending breakdown across groups")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.40))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        // MARK: Stats Row
                        HStack(spacing: 0) {
                            StatBadge(
                                icon: "banknote.fill",
                                label: "Total Spent",
                                value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.0f", totalSpent))",
                                color: Theme.secondaryAccent
                            )
                            Divider().frame(height: 44).background(Color.white.opacity(0.10))
                            StatBadge(
                                icon: "arrow.down.circle.fill",
                                label: "Owed to You",
                                value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.0f", overallBalance > 0 ? overallBalance : 0))",
                                color: Theme.successColor
                            )
                            Divider().frame(height: 44).background(Color.white.opacity(0.10))
                            StatBadge(
                                icon: "arrow.up.circle.fill",
                                label: "You Owe",
                                value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.0f", abs(totalOwed)))",
                                color: Theme.dangerColor
                            )
                        }
                        .padding(.vertical, 20)
                        .accentCard(cornerRadius: 24)
                        .padding(.horizontal, 20)

                        // MARK: Chart
                        if categoryData.isEmpty {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.primaryAccent.opacity(0.08))
                                        .frame(width: 100, height: 100)
                                    Image(systemName: "chart.pie.fill")
                                        .font(.system(size: 44))
                                        .foregroundColor(Theme.primaryAccent.opacity(0.35))
                                }
                                Text("No spending data yet.")
                                    .foregroundColor(.white.opacity(0.45))
                                    .font(.subheadline)
                            }
                            .padding(.top, 30)
                        } else {
                            if #available(iOS 16.0, *) {
                                iOS16ChartView(categoryData: categoryData.map { ($0.category, $0.amount) })
                            } else {
                                iOS15ChartView(categoryData: categoryData, appear: appear)
                            }
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .navigationBarHidden(true)
            .onAppear { withAnimation(.easeOut(duration: 0.6)) { appear = true } }
        }
    }
}

// MARK: - iOS 15 Custom Chart
struct iOS15ChartView: View {
    let categoryData: [(category: String, amount: Double, icon: String, color: Color)]
    var appear: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Spending by Category")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            let maxAmount = categoryData.map { $0.amount }.max() ?? 1.0

            VStack(spacing: 18) {
                ForEach(Array(categoryData.enumerated()), id: \.element.category) { index, item in
                    HStack(spacing: 12) {
                        IconBadge(systemName: item.icon, color: item.color, size: 34, iconSize: 13)

                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(item.category)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.80))
                                Spacer()
                                Text(String(format: "%.0f", item.amount))
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.60))
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white.opacity(0.06))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(LinearGradient(
                                            colors: [item.color, item.color.opacity(0.5)],
                                            startPoint: .leading, endPoint: .trailing
                                        ))
                                        .frame(
                                            width: appear
                                                ? max(CGFloat(item.amount / maxAmount) * geo.size.width, 8)
                                                : 0,
                                            height: 8
                                        )
                                        .animation(
                                            .spring(response: 0.6, dampingFraction: 0.8)
                                            .delay(Double(index) * 0.08),
                                            value: appear
                                        )
                                }
                            }
                            .frame(height: 8)
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
    let categoryData: [(category: String, amount: Double)]

    var body: some View {
        #if canImport(Charts)
        VStack(alignment: .leading, spacing: 18) {
            Text("Spending by Category")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            Chart {
                ForEach(categoryData, id: \.category) { item in
                    BarMark(
                        x: .value("Amount", item.amount),
                        y: .value("Category", item.category)
                    )
                    .foregroundStyle(Theme.primaryGradient)
                    .cornerRadius(6)
                }
            }
            .frame(height: CGFloat(categoryData.count) * 46 + 20)
            .chartXAxis {
                AxisMarks(values: .automatic) {
                    AxisValueLabel().foregroundStyle(Color.white.opacity(0.45))
                }
            }
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel()
                        .foregroundStyle(Color.white)
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
