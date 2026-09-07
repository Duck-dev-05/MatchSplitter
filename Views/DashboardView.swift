import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    @State private var appear = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.06, green: 0.06, blue: 0.14),
                        Color(red: 0.10, green: 0.08, blue: 0.22)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MatchSplitter")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            Text("Split expenses, settle debts.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.55))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        .padding(.bottom, 28)

                        // Groups Section
                        VStack(spacing: 14) {
                            if viewModel.groups.isEmpty {
                                EmptyGroupsView()
                                    .padding(.top, 60)
                            } else {
                                ForEach(Array(viewModel.groups.enumerated()), id: \.element.id) { index, group in
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
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .bottomTrailing) {
                // Floating Add Button
                Button(action: { showingAddGroup = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.43, green: 0.26, blue: 0.98), Color(red: 0.60, green: 0.20, blue: 0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: Color(red: 0.43, green: 0.26, blue: 0.98).opacity(0.5), radius: 15, x: 0, y: 8)
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
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

    // Unique accent color per group based on name hash
    var accentColor: Color {
        let colors: [Color] = [
            Color(red: 0.43, green: 0.26, blue: 0.98),
            Color(red: 0.13, green: 0.67, blue: 0.89),
            Color(red: 0.95, green: 0.37, blue: 0.54),
            Color(red: 0.20, green: 0.80, blue: 0.60)
        ]
        let index = abs(group.name.hashValue) % colors.count
        return colors[index]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 46, height: 46)
                    Image(systemName: "person.3.fill")
                        .foregroundColor(accentColor)
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("\(group.members.count) members")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.leading, 4)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }

            Divider()
                .background(Color.white.opacity(0.08))

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Spent")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.45))
                        .textCase(.uppercase)
                    Text(String(format: "฿%.2f", totalSpent))
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(accentColor)
                }

                Spacer()

                Text("\(group.expenses.count) expenses")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.45))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(20)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.14, green: 0.13, blue: 0.24))
                .shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
}

struct EmptyGroupsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 56))
                .foregroundColor(.white.opacity(0.15))
            Text("No Groups Yet")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            Text("Tap the + button to create\nyour first expense group.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.35))
                .multilineTextAlignment(.center)
        }
    }
}
