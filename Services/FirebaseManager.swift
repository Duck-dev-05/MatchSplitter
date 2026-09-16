import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    private var listeners: [UUID: ListenerRegistration] = [:]
    
    private init() {}
    
    // MARK: - Auth
    func createUser(email: String, password: String) async throws -> AuthDataResult {
        return try await auth.createUser(withEmail: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        return try await auth.signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    // MARK: - User Management
    func saveUser(_ user: User) async throws {
        let userData = try JSONEncoder().encode(user)
        guard let userJsonString = String(data: userData, encoding: .utf8) else { return }
        
        let data: [String: Any] = [
            "id": user.id.uuidString,
            "email": user.email ?? "",
            "user_data": userJsonString,
            "last_updated": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(user.id.uuidString).setData(data, merge: true)
    }
    
    func fetchUser(byEmail email: String) async throws -> User? {
        let snapshot = try await db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()
            
        guard let document = snapshot.documents.first else { return nil }
        
        let data = document.data()
        if let userJsonString = data["user_data"] as? String,
           let userData = userJsonString.data(using: .utf8) {
            return try JSONDecoder().decode(User.self, from: userData)
        }
        return nil
    }
    
    func fetchAllUsersCaseInsensitive(byEmail email: String) async throws -> [User] {
        let snapshot = try await db.collection("users").getDocuments()
        let lowerEmail = email.lowercased()
        var matchedUsers: [User] = []
        
        for document in snapshot.documents {
            let data = document.data()
            if let userEmail = data["email"] as? String, userEmail.lowercased() == lowerEmail {
                if let userJsonString = data["user_data"] as? String,
                   let userData = userJsonString.data(using: .utf8),
                   let user = try? JSONDecoder().decode(User.self, from: userData) {
                    matchedUsers.append(user)
                }
            }
        }
        return matchedUsers
    }
    
    func fetchUser(byId id: String) async throws -> User? {
        let snapshot = try await db.collection("users").document(id).getDocument()
        guard let data = snapshot.data() else { return nil }
        
        if let userJsonString = data["user_data"] as? String,
           let userData = userJsonString.data(using: .utf8) {
            return try JSONDecoder().decode(User.self, from: userData)
        }
        return nil
    }
    
    // MARK: - Save Group to Firebase
    func saveGroup(_ group: Group) async throws {
        let groupData = try JSONEncoder().encode(group)
        guard let groupJsonString = String(data: groupData, encoding: .utf8) else { return }
        
        let data: [String: Any] = [
            "id": group.id.uuidString,
            "member_ids": group.members.map { $0.id.uuidString },
            "group_data": groupJsonString,
            "last_updated": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("groups").document(group.id.uuidString).setData(data, merge: true)
    }
    
    // MARK: - Fetch Group from Firebase
    func fetchGroup(id: UUID) async throws -> Group? {
        let snapshot = try await db.collection("groups").document(id.uuidString).getDocument()
        
        guard let data = snapshot.data(),
              let groupJsonString = data["group_data"] as? String,
              let groupData = groupJsonString.data(using: .utf8) else {
            return nil
        }
        
        return try JSONDecoder().decode(Group.self, from: groupData)
    }
    
    // MARK: - Delete Group from Firebase
    func deleteGroup(id: String) async throws {
        try await db.collection("groups").document(id).delete()
    }
    
    // MARK: - Fetch Groups for User
    func fetchGroupsForUser(userId: UUID) async throws -> [Group] {
        let snapshot = try await db.collection("groups")
            .whereField("member_ids", arrayContains: userId.uuidString)
            .getDocuments()
            
        var userGroups: [Group] = []
        for document in snapshot.documents {
            let data = document.data()
            if let groupJsonString = data["group_data"] as? String,
               let groupData = groupJsonString.data(using: .utf8),
               let group = try? JSONDecoder().decode(Group.self, from: groupData) {
                userGroups.append(group)
            }
        }
        return userGroups
    }
    
    // MARK: - Realtime Subscriptions
    func listenForUpdates(groupId: UUID, onChange: @escaping (Group) -> Void) {
        listeners[groupId]?.remove()
        
        let listener = db.collection("groups").document(groupId.uuidString)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot,
                      let data = document.data(),
                      let groupJsonString = data["group_data"] as? String,
                      let groupData = groupJsonString.data(using: .utf8) else {
                    return
                }
                
                if let updatedGroup = try? JSONDecoder().decode(Group.self, from: groupData) {
                    DispatchQueue.main.async {
                        onChange(updatedGroup)
                    }
                }
            }
        
        listeners[groupId] = listener
    }
    
    private var userGroupsListener: ListenerRegistration?
    
    func stopListeningToUserGroups() {
        userGroupsListener?.remove()
        userGroupsListener = nil
    }
    
    func listenToUserGroups(userId: UUID, onChange: @escaping ([Group]) -> Void) {
        userGroupsListener?.remove()
        
        let listener = db.collection("groups")
            .whereField("member_ids", arrayContains: userId.uuidString)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                var userGroups: [Group] = []
                for document in documents {
                    let data = document.data()
                    if let groupJsonString = data["group_data"] as? String,
                       let groupData = groupJsonString.data(using: .utf8),
                       let group = try? JSONDecoder().decode(Group.self, from: groupData) {
                        userGroups.append(group)
                    }
                }
                
                DispatchQueue.main.async {
                    onChange(userGroups)
                }
            }
            
        userGroupsListener = listener
    }
    
    // MARK: - Notifications
    func updateFCMToken(_ token: String, forUserId userId: String) async throws {
        try await db.collection("users").document(userId).setData(["fcmToken": token], merge: true)
    }
    
    func sendNotification(to userIds: [String], title: String, body: String, data: [String: String] = [:]) {
        for userId in userIds {
            let notificationId = UUID().uuidString
            let payload: [String: Any] = [
                "id": notificationId,
                "userId": userId,
                "title": title,
                "body": body,
                "data": data,
                "timestamp": FieldValue.serverTimestamp(),
                "status": "pending" // A hypothetical Cloud Function would listen to this collection and send the actual push notification.
            ]
            db.collection("notifications").document(notificationId).setData(payload)
        }
    }
}
