import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    
    // Compute total spent per category across all groups
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
    
    // Calculate total money you've paid overall vs what you owe
    var overallBalance: Double {
        let balances = viewModel.calculateGlobalBalances()
        var net = 0.0
        for (_, curBalances) in balances {
            for (_, amount) in curBalances {
                net += amount // Positive means they owe me
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
                                    
                                    Text(overallBalance >= 0 ? "+฿\(String(format: "%.2f", overallBalance))" : "-฿\(String(format: "%.2f", abs(overallBalance)))")
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
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
