import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    @State private var appear = false

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MatchSplitter")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            Text("Split expenses, settle debts.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 32)

                        // Groups Section
                        VStack(spacing: 16) {
                            if viewModel.groups.isEmpty {
                                EmptyGroupsView()
                                    .padding(.top, 60)
                            } else {
                                ForEach(Array(viewModel.groups.enumerated()), id: \.element.id) { (index, group) in
                                    NavigationLink(destination: GroupDetailView(group: group)) {
                                        GroupCardView(group: group)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .offset(y: appear ? 0 : 40)
                                    .opacity(appear ? 1 : 0)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.08),
                                        value: appear
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // Space for floating button
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .bottomTrailing) {
                Button(action: { showingAddGroup = true }) {
                    ZStack {
                        Circle()
                            .fill(Theme.primaryGradient)
                            .frame(width: 64, height: 64)
                            .shadow(color: Theme.primaryAccent.opacity(0.4), radius: 15, x: 0, y: 8)
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, 28)
            }
            .alert("New Group", isPresented: $showingAddGroup) {
                TextField("Group Name", text: $newGroupName)
                Button("Create") {
                    if !newGroupName.isEmpty {
                        withAnimation(.spring()) {
                            viewModel.addGroup(name: newGroupName)
                            newGroupName = ""
                        }
                    }
                }
                Button("Cancel", role: .cancel) { newGroupName = "" }
            }
        }
        .onAppear { appear = true }
    }
}

struct GroupCardView: View {
    var group: Group

    var totalSpent: Double {
        group.expenses.reduce(0) { $0 + $1.amount }
    }

    var accentColor: Color {
        let colors: [Color] = [
            Theme.primaryAccent,
            Color(red: 0.13, green: 0.67, blue: 0.89),
            Color(red: 0.95, green: 0.37, blue: 0.54),
            Color(red: 0.20, green: 0.80, blue: 0.60)
        ]
        let index = abs(group.name.hashValue) % colors.count
        return colors[index]
    }

    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(accentColor.opacity(0.15))
                                .frame(width: 50, height: 50)
                            Image(systemName: "person.3.fill")
                                .foregroundColor(accentColor)
                                .font(.system(size: 20))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(group.name)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(group.members.count) members")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.leading, 6)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.3))
                    }

                    Divider()
                        .background(Color.white.opacity(0.08))

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total Spent")
                                .font(.caption2.weight(.medium))
                                .foregroundColor(.white.opacity(0.45))
                                .textCase(.uppercase)
                            Text("\(group.currency.symbol)\(String(format: "%.2f", totalSpent))")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Text("\(group.expenses.count) expenses")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                }
                .padding(20)
            ),
            cornerRadius: 24
        )
    }
}

struct EmptyGroupsView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 100, height: 100)
                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(.bottom, 8)
            
            Text("No Groups Yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            Text("Tap the + button to create\nyour first expense group.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
    }
}
