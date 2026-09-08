import SwiftUI

struct GroupMembersView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddMember = false
    @State private var newName = ""
    @State private var newPaymentID = ""

    var currentGroup: Group {
        viewModel.groups.first(where: { $0.id == group.id }) ?? group
    }

    let avatarColors: [Color] = [
        Theme.primaryAccent,
        Color(red: 0.13, green: 0.67, blue: 0.89),
        Color(red: 0.95, green: 0.37, blue: 0.54),
        Color(red: 0.20, green: 0.80, blue: 0.60),
        Color(red: 0.98, green: 0.60, blue: 0.20)
    ]

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(Array(currentGroup.members.enumerated()), id: \.element.id) { (index, member) in
                        MemberRowView(
                            member: member,
                            color: avatarColors[index % avatarColors.count]
                        )
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddMember = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 32, height: 32)
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .alert("Add Member", isPresented: $showingAddMember) {
            TextField("Name", text: $newName)
            TextField("Payment ID (Optional)", text: $newPaymentID)
            Button("Add") {
                if !newName.isEmpty {
                    withAnimation(.spring()) {
                        viewModel.addMember(to: currentGroup, name: newName, paymentID: newPaymentID)
                    }
                    newName = ""
                    newPaymentID = ""
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct MemberRowView: View {
    var member: User
    var color: Color

    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: 5)
                        Text(member.name.prefix(1).uppercased())
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(member.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        if let pid = member.paymentID, !pid.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 12))
                                Text(pid)
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white.opacity(0.5))
                        } else {
                            Text("No payment ID")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }

                    Spacer()
                }
                .padding(16)
            ),
            cornerRadius: 20
        )
    }
}
