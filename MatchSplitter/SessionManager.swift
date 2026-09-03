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
    
    func login(user: User, context: NSManagedObjectContext) {
        self.currentUser = user
        UserDefaults.standard.set(user.id.uuidString, forKey: "lastUserID")
        
        // Auto-select group if they only have exactly 1
        let groupReq: NSFetchRequest<BusinessGroup> = BusinessGroup.fetchRequest()
        groupReq.predicate = NSPredicate(format: "ownerID == %@", user.id as CVarArg)
        
        if let groups = try? context.fetch(groupReq), groups.count == 1 {
            selectGroup(group: groups[0])
        }
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
                
                // If no group is selected (e.g. cleared or first time), but the user has exactly 1 group, auto-select it
                if self.currentGroup == nil {
                    let groupReq: NSFetchRequest<BusinessGroup> = BusinessGroup.fetchRequest()
                    groupReq.predicate = NSPredicate(format: "ownerID == %@", user.id as CVarArg)
                    if let groups = try? context.fetch(groupReq), groups.count == 1 {
                        self.selectGroup(group: groups[0])
                    }
                }
            }
        }
    }
}
