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
                        NavigationLink(destination: InvoicesView(group: currentGroup, user: member)) {
                            MemberRowView(
                                member: member,
                                color: avatarColors[index % avatarColors.count]
                            )
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    NavigationLink(destination: TeamQRInviteView(group: currentGroup)) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 32, height: 32)
                            Image(systemName: "qrcode")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
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
        }
        .alert("Add Member(s)", isPresented: $showingAddMember) {
            TextField("Name (comma separated for multiple)", text: $newName)
            TextField("Payment ID (Optional)", text: $newPaymentID)
            Button("Add") {
                if !newName.isEmpty {
                    withAnimation(.spring()) {
                        let names = newName.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                        for name in names {
                            viewModel.addMember(to: currentGroup, name: name, paymentID: names.count == 1 ? newPaymentID : "")
                        }
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
        HStack(spacing: 16) {
            GradientAvatar(
                name: member.name,
                size: 50,
                gradient: LinearGradient(
                    colors: [color, color.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

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

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.22))
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
}
