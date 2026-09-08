import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    
    var categoryData: [(category: String, amount: Double)] {
        var totals: [ExpenseCategory: Double] = [:]
        
        for group in viewModel.groups {
            for expense in group.expenses {
                totals[expense.category, default: 0.0] += expense.amount
            }
        }
        
        return totals.map { (category: $0.key.rawValue, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    var overallBalance: Double {
        let balances = viewModel.calculateGlobalBalances()
        var net = 0.0
        for (_, curBalances) in balances {
            for (_, amount) in curBalances {
                net += amount
            }
        }
        return net
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Text("Analytics")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        
                        // Net Balance Card
                        Theme.applyGlassCard(
                            to: AnyView(
                                VStack(spacing: 8) {
                                    Text("NET BALANCE")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.white.opacity(0.5))
                                        .textCase(.uppercase)
                                    
                                    let currencySymbol = viewModel.defaultCurrency.symbol
                                    Text(overallBalance >= 0 ? "+\(currencySymbol)\(String(format: "%.2f", overallBalance))" : "-\(currencySymbol)\(String(format: "%.2f", abs(overallBalance)))")
                                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                                        .foregroundColor(overallBalance >= 0 ? .green : Color(red: 0.95, green: 0.37, blue: 0.54))
                                    
                                    Text(overallBalance >= 0 ? "You are owed overall" : "You owe overall")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(24)
                                .frame(maxWidth: .infinity)
                            ),
                            cornerRadius: 24
                        )
                        .padding(.horizontal, 20)
                        
                        // Category Chart
                        if categoryData.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "chart.pie.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.2))
                                Text("No spending data yet.")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.top, 40)
                        } else {
                            if #available(iOS 16.0, *) {
                                // iOS 16+ UI with Swift Charts
                                iOS16ChartView(categoryData: categoryData)
                            } else {
                                // Fallback UI for iOS 15
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

// MARK: - iOS 15 Fallback View
struct iOS15ChartView: View {
    let categoryData: [(category: String, amount: Double)]
    
    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                VStack(alignment: .leading, spacing: 24) {
                    Text("Spending by Category (Legacy)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    let maxAmount = categoryData.map { $0.amount }.max() ?? 1.0
                    
                    VStack(spacing: 16) {
                        ForEach(categoryData, id: \.category) { item in
                            HStack(spacing: 12) {
                                Text(item.category)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 80, alignment: .leading)
                                
                                GeometryReader { geometry in
                                    let barWidth = CGFloat(item.amount / maxAmount) * geometry.size.width
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Theme.primaryGradient)
                                        .frame(width: max(barWidth, 4), height: 16)
                                }
                                .frame(height: 16)
                                
                                Text(String(format: "%.0f", item.amount))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(width: 40, alignment: .trailing)
                            }
                        }
                    }
                }
                .padding(24)
            ),
            cornerRadius: 24
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - iOS 16+ View
@available(iOS 16.0, *)
struct iOS16ChartView: View {
    let categoryData: [(category: String, amount: Double)]
    
    var body: some View {
        #if canImport(Charts)
        Theme.applyGlassCard(
            to: AnyView(
                VStack(alignment: .leading, spacing: 20) {
                    Text("Spending by Category")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Chart {
                        ForEach(categoryData, id: \.category) { item in
                            BarMark(
                                x: .value("Amount", item.amount),
                                y: .value("Category", item.category)
                            )
                            .foregroundStyle(Theme.primaryGradient)
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 250)
                    .chartXAxis {
                        AxisMarks(values: .automatic) {
                            AxisValueLabel()
                                .foregroundStyle(Color.white.opacity(0.5))
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
                .padding(24)
            ),
            cornerRadius: 24
        )
        .padding(.horizontal, 20)
        #else
        EmptyView()
        #endif
    }
}
