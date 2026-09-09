import SwiftUI

struct ActivityFeedView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    
    // Extract expenses from all groups, sorted by date.
    var activities: [(group: Group, expense: Expense)] {
        var all: [(Group, Expense)] = []
        for group in viewModel.groups {
            for exp in group.expenses {
                all.append((group, exp))
            }
        }
        return all.sorted { $0.1.date > $1.1.date }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                if activities.isEmpty {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 100, height: 100)
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.2))
                        }
                        
                        Text("No Activity")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        Text("Your recent group activity will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.4))
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            Text("Recent Activity")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            
                            ForEach(activities, id: \.expense.id) { item in
                                ActivityRow(group: item.group, expense: item.expense)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ActivityRow: View {
    var group: Group
    var expense: Expense
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: expense.date, relativeTo: Date())
    }
    
    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Theme.primaryAccent.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: expense.category.iconName)
                            .foregroundColor(Theme.primaryAccent)
                            .font(.system(size: 18))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(expense.paidBy.name)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("paid for")
                                .foregroundColor(.white.opacity(0.6))
                            Text(expense.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 15))
                        .lineLimit(2)
                        
                        HStack {
                            Text("in **\(group.name)**")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text(timeAgo)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(group.currency.symbol)\(String(format: "%.0f", expense.amount))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.secondaryAccent)
                }
                .padding(16)
            ),
            cornerRadius: 20
        )
    }
}
