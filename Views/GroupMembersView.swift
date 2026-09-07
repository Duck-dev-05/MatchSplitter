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
    
    var body: some View {
        List {
            ForEach(currentGroup.members) { member in
                HStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.indigo, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(member.name.prefix(1).uppercased())
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(member.name).font(.headline)
                        if let pid = member.paymentID, !pid.isEmpty {
                            Text(pid).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Members")
        .toolbar {
            Button(action: { showingAddMember = true }) {
                Image(systemName: "person.badge.plus")
            }
        }
        .alert("Add Member", isPresented: $showingAddMember) {
            TextField("Name", text: $newName)
            TextField("Payment ID (Optional)", text: $newPaymentID)
            Button("Add") {
                if !newName.isEmpty {
                    viewModel.addMember(to: currentGroup, name: newName, paymentID: newPaymentID)
                    newName = ""
                    newPaymentID = ""
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}
