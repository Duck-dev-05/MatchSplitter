import Foundation

class DeepLinkManager {
    static let shared = DeepLinkManager()
    
    private init() {}
    
    func handleDeepLink(_ url: URL, viewModel: GroupViewModel) {
        // Accept custom scheme: matchsplitter://join?id=UUID
        // Accept universal link: https://matchsplitter.com/join?id=UUID
        let isCustomScheme = url.scheme == "matchsplitter" && url.host == "join"
        let isUniversalLink = (url.scheme == "https" || url.scheme == "http") && url.host == "matchsplitter.com" && url.path == "/join"
        
        guard isCustomScheme || isUniversalLink else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let idString = components?.queryItems?.first(where: { $0.name == "id" })?.value,
           let groupId = UUID(uuidString: idString) {
            
            // Check if user is logged in
            guard let user = viewModel.currentUser else { return }
            
            // Find the group and add the user if not already in it
            Task {
                var targetGroup: Group? = nil
                
                if let index = viewModel.groups.firstIndex(where: { $0.id == groupId }) {
                    targetGroup = viewModel.groups[index]
                } else {
                    // Fetch from Firebase if not found locally
                    if let fetchedGroup = try? await FirebaseManager.shared.fetchGroup(id: groupId) {
                        targetGroup = fetchedGroup
                        await MainActor.run {
                            viewModel.groups.append(fetchedGroup)
                        }
                    }
                }
                
                if var group = targetGroup {
                    if !group.members.contains(where: { $0.id == user.id }) {
                        group.members.append(user)
                        
                        await MainActor.run {
                            if let index = viewModel.groups.firstIndex(where: { $0.id == groupId }) {
                                viewModel.groups[index] = group
                            }
                            viewModel.saveData()
                        }
                        
                        // Push immediately to Firebase so creator sees it
                        try? await FirebaseManager.shared.saveGroup(group)
                    }
                }
            }
        }
    }
}
