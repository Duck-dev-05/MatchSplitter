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
        Color(red: 0.43, green: 0.26, blue: 0.98),
        Color(red: 0.13, green: 0.67, blue: 0.89),
        Color(red: 0.95, green: 0.37, blue: 0.54),
        Color(red: 0.20, green: 0.80, blue: 0.60),
        Color(red: 0.98, green: 0.60, blue: 0.20)
    ]

    var body: some View {
        ZStack {
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
                VStack(spacing: 12) {
                    ForEach(Array(currentGroup.members.enumerated()), id: \.element.id) { (index, member) in
                        MemberRowView(
                            member: member,
                            color: avatarColors[index % avatarColors.count]
                        )
                    }
                }
                .padding(20)
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
                            .font(.system(size: 13, weight: .semibold))
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
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                Text(member.name.prefix(1).uppercased())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                if let pid = member.paymentID, !pid.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 10))
                        Text(pid)
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.4))
                } else {
                    Text("No payment ID")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.25))
                }
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.14, green: 0.13, blue: 0.24))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
