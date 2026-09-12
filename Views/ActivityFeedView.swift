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

                AmbientGlob(color: Theme.primaryAccent, size: 240, blurRadius: 80, opacity: 0.09, offsetX: 100, offsetY: -50)
                    .ignoresSafeArea()

                if activities.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Page Header with live count chip
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Activity")
                                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                    Text("All group transactions")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.40))
                                }
                                Spacer()
                                // Live count chip
                                HStack(spacing: 5) {
                                    PulseDot()
                                    Text("\(activities.count)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color.white.opacity(0.09))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1))
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 22)

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
                                .padding(.bottom, 20)
                            }

                            // Bottom fade hint
                            LinearGradient(
                                colors: [.clear, Theme.backgroundEnd.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 40)
                            .allowsHitTesting(false)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear { withAnimation { appear = true } }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.07))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.25))
            }
            Text("No Activity Yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.80))
            Text("Your recent group activity will appear here.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.40))
                .multilineTextAlignment(.center)
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
        formatter.unitsStyle = .abbreviated
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
        HStack(spacing: 14) {
            // Category icon + pulse dot
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.14))
                        .frame(width: 46, height: 46)
                    Image(systemName: expense.category.iconName)
                        .foregroundColor(categoryColor)
                        .font(.system(size: 17, weight: .semibold))
                }

                if isRecent {
                    PulseDot()
                        .offset(x: 3, y: -3)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 4) {
                    Text(expense.paidBy.name)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("paid for")
                        .foregroundColor(.white.opacity(0.55))
                    Text(expense.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .font(.system(size: 14))
                .lineLimit(1)

                HStack(spacing: 6) {
                    // Group chip
                    Text(group.name)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.primaryAccent)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Theme.primaryAccent.opacity(0.14))
                        .clipShape(Capsule())

                    Spacer()

                    Text(timeAgo)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.35))
                }
            }

            Text("\(group.currency.symbol)\(String(format: "%.0f", expense.amount))")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Theme.secondaryAccent)
        }
        .padding(16)
        .glassCard(cornerRadius: 18)
    }
}

// MARK: - Pulse Dot
struct PulseDot: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.successColor.opacity(pulse ? 0 : 0.35))
                .frame(width: 12, height: 12)
                .scaleEffect(pulse ? 1.7 : 1.0)
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
