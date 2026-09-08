import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: GroupViewModel

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
            case .food:          color = Color(red: 1.0, green: 0.65, blue: 0.15)
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
                        // Page title
                        Text("Analytics")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)

                        // 3-column stats row
                        Theme.applyAccentCard(
                            to: AnyView(
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
                            ),
                            cornerRadius: 24
                        )
                        .padding(.horizontal, 20)

                        // Chart
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
                                iOS15ChartView(categoryData: categoryData)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - iOS 15 Custom Chart
struct iOS15ChartView: View {
    let categoryData: [(category: String, amount: Double, icon: String, color: Color)]

    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                VStack(alignment: .leading, spacing: 20) {
                    Text("Spending by Category")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)

                    let maxAmount = categoryData.map { $0.amount }.max() ?? 1.0

                    VStack(spacing: 14) {
                        ForEach(categoryData, id: \.category) { item in
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(item.color.opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: item.icon)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(item.color)
                                }

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white.opacity(0.06))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 12)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(LinearGradient(
                                                colors: [item.color, item.color.opacity(0.6)],
                                                startPoint: .leading, endPoint: .trailing))
                                            .frame(width: max(CGFloat(item.amount / maxAmount) * geo.size.width, 6))
                                            .frame(height: 12)
                                    }
                                }
                                .frame(height: 12)

                                Text(String(format: "%.0f", item.amount))
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.55))
                                    .frame(width: 48, alignment: .trailing)
                            }

                            Text(item.category)
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.40))
                                .padding(.leading, 44)
                        }
                    }
                }
                .padding(22)
            ),
            cornerRadius: 24
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - iOS 16+ Chart
@available(iOS 16.0, *)
struct iOS16ChartView: View {
    let categoryData: [(category: String, amount: Double)]

    var body: some View {
        #if canImport(Charts)
        Theme.applyGlassCard(
            to: AnyView(
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
                            .cornerRadius(5)
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
            ),
            cornerRadius: 24
        )
        .padding(.horizontal, 20)
        #else
        EmptyView()
        #endif
    }
}
