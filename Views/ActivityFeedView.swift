import SwiftUI

struct ActivityFeedView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var appear = false

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

    // Group by date bucket
    var grouped: [(bucket: String, items: [(group: Group, expense: Expense)])] {
        let now = Date()
        let calendar = Calendar.current
        var todayItems: [(Group, Expense)] = []
        var yesterdayItems: [(Group, Expense)] = []
        var olderItems: [(Group, Expense)] = []

        for item in activities {
            if calendar.isDateInToday(item.expense.date) {
                todayItems.append(item)
            } else if calendar.isDateInYesterday(item.expense.date) {
                yesterdayItems.append(item)
            } else {
                _ = now  // silence warning
                olderItems.append(item)
            }
        }

        var result: [(String, [(Group, Expense)])] = []
        if !todayItems.isEmpty     { result.append(("Today", todayItems)) }
        if !yesterdayItems.isEmpty { result.append(("Yesterday", yesterdayItems)) }
        if !olderItems.isEmpty     { result.append(("Older", olderItems)) }
        return result
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                // Glow blob
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.08))
                    .frame(width: 240, height: 240)
                    .blur(radius: 80)
                    .offset(x: 100, y: -50)
                    .ignoresSafeArea()

                if activities.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Page Header
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Recent Activity")
                                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                    Text("\(activities.count) transactions")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.40))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 20)

                            // Grouped sections
                            ForEach(grouped, id: \.bucket) { section in
                                VStack(spacing: 10) {
                                    SectionHeader(title: section.bucket)
                                        .padding(.bottom, 8)

                                    ForEach(Array(section.items.enumerated()), id: \.element.expense.id) { index, item in
                                        ActivityRow(group: item.group, expense: item.expense)
                                            .offset(y: appear ? 0 : 18)
                                            .opacity(appear ? 1 : 0)
                                            .animation(
                                                .spring(response: 0.45, dampingFraction: 0.75)
                                                .delay(Double(index) * 0.06),
                                                value: appear
                                            )
                                    }
                                }
                                .padding(.bottom, 16)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear { withAnimation { appear = true } }
        }
    }

    private var emptyState: some View {
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
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    var group: Group
    var expense: Expense

    var isRecent: Bool {
        Date().timeIntervalSince(expense.date) < 86400  // within 24h
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: expense.date, relativeTo: Date())
    }

    var categoryColor: Color {
        switch expense.category {
        case .food:          return Theme.warmGold
        case .transport:     return Theme.secondaryAccent
        case .rent:          return Theme.primaryAccent
        case .entertainment: return Theme.dangerColor
        case .travel:        return Theme.successColor
        case .general:       return .white
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.14))
                    .frame(width: 48, height: 48)
                Image(systemName: expense.category.iconName)
                    .foregroundColor(categoryColor)
                    .font(.system(size: 18))

                // Live pulse dot for recent activities
                if isRecent {
                    PulseDot()
                        .offset(x: 16, y: -16)
                }
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
        .glassCard(cornerRadius: 20)
    }
}

// MARK: - Pulse Dot
struct PulseDot: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.successColor.opacity(pulse ? 0 : 0.4))
                .frame(width: 12, height: 12)
                .scaleEffect(pulse ? 1.6 : 1.0)
            Circle()
                .fill(Theme.successColor)
                .frame(width: 7, height: 7)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}
