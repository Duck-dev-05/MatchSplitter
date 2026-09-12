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
                            analyticsStatCard(
                                icon: "banknote.fill",
                                label: "Total Spent",
                                value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.0f", totalSpent))",
                                color: Theme.secondaryAccent
                            )
                            analyticsStatCard(
                                icon: "arrow.down.circle.fill",
                                label: "Owed to You",
                                value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.0f", overallBalance > 0 ? overallBalance : 0))",
                                color: Theme.successColor
                            )
                            analyticsStatCard(
                                icon: "arrow.up.circle.fill",
                                label: "You Owe",
                                value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.0f", abs(totalOwed)))",
                                color: Theme.dangerColor
                            )
                        }
                        .padding(.horizontal, 20)

                        // MARK: Chart
                        if categoryData.isEmpty {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.primaryAccent.opacity(0.07))
                                        .frame(width: 110, height: 110)
                                    Circle()
                                        .fill(Theme.primaryAccent.opacity(0.12))
                                        .frame(width: 78, height: 78)
                                    Image(systemName: "chart.pie.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(Theme.primaryAccent.opacity(0.50))
                                }
                                Text("No spending data yet.")
                                    .foregroundColor(.white.opacity(0.40))
                                    .font(.system(size: 15, weight: .medium))
                                Text("Add expenses to groups to see your breakdown here.")
                                    .foregroundColor(.white.opacity(0.30))
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
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

    // MARK: - Analytics Stat Card
    private func analyticsStatCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.45))
                .textCase(.uppercase)
                .kerning(0.6)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .premiumCard(cornerRadius: 18, accentColor: color)
    }
}

// MARK: - iOS 15 Custom Chart
struct iOS15ChartView: View {
    let categoryData: [(category: String, amount: Double, icon: String, color: Color)]
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
                ForEach(Array(categoryData.enumerated()), id: \.element.category) { index, item in
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
    let categoryData: [(category: String, amount: Double)]

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
