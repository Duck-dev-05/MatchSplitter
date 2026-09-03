import SwiftUI
import CoreData

class SessionManager: ObservableObject {
    @Published var currentUser: User?
    @Published var currentGroup: BusinessGroup?
    
    // Check if the user is authenticated and has a group selected
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    var hasActiveGroup: Bool {
        currentGroup != nil
    }
    
    func login(user: User) {
        self.currentUser = user
        // We could also persist this to UserDefaults to auto-login next time
        UserDefaults.standard.set(user.id.uuidString, forKey: "lastUserID")
    }
    
    func logout() {
        self.currentUser = nil
        self.currentGroup = nil
        UserDefaults.standard.removeObject(forKey: "lastUserID")
        UserDefaults.standard.removeObject(forKey: "lastGroupID")
    }
    
    func selectGroup(group: BusinessGroup) {
        self.currentGroup = group
        UserDefaults.standard.set(group.id.uuidString, forKey: "lastGroupID")
    }
    
    func clearGroup() {
        self.currentGroup = nil
        UserDefaults.standard.removeObject(forKey: "lastGroupID")
    }
    
    func autoLogin(context: NSManagedObjectContext) {
        if let userIDString = UserDefaults.standard.string(forKey: "lastUserID"),
           let userID = UUID(uuidString: userIDString) {
            
            let request: NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", userID as CVarArg)
            
            if let user = try? context.fetch(request).first {
                self.currentUser = user
                
                // Try to load last group
                if let groupIDString = UserDefaults.standard.string(forKey: "lastGroupID"),
                   let groupID = UUID(uuidString: groupIDString) {
                    
                    let groupReq: NSFetchRequest<BusinessGroup> = BusinessGroup.fetchRequest()
                    groupReq.predicate = NSPredicate(format: "id == %@", groupID as CVarArg)
                    
                    if let group = try? context.fetch(groupReq).first {
                        self.currentGroup = group
                    }
                }
            }
        }
    }
}
