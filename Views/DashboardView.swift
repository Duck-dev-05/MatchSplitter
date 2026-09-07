import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groups) { group in
                    NavigationLink(destination: GroupDetailView(group: group)) {
                        Text(group.name)
                    }
                }
            }
            .navigationTitle("MatchSplitter")
            .toolbar {
                Button(action: { showingAddGroup = true }) {
                    Image(systemName: "plus")
                }
            }
            .alert("New Group", isPresented: $showingAddGroup) {
                TextField("Group Name", text: $newGroupName)
                Button("Add") {
                    if !newGroupName.isEmpty {
                        viewModel.addGroup(name: newGroupName)
                        newGroupName = ""
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}
