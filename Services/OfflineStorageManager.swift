import Foundation

// A lightweight offline storage manager using UserDefaults for small configurations 
// and providing a structural base if migrating to SwiftData / CoreData in the future.
class OfflineStorageManager {
    static let shared = OfflineStorageManager()
    
    private let userDefaults = UserDefaults.standard
    private let groupsKey = "offline_groups"
    
    private init() {}
    
    // Save groups locally
    func saveGroups(_ groups: [Group]) {
        do {
            let data = try JSONEncoder().encode(groups)
            userDefaults.set(data, forKey: groupsKey)
        } catch {
            print("Failed to encode groups for offline storage: \(error.localizedDescription)")
        }
    }
    
    // Retrieve cached groups
    func fetchGroups() -> [Group]? {
        guard let data = userDefaults.data(forKey: groupsKey) else { return nil }
        do {
            let groups = try JSONDecoder().decode([Group].self, from: data)
            return groups
        } catch {
            print("Failed to decode groups from offline storage: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Clear offline cache
    func clearCache() {
        userDefaults.removeObject(forKey: groupsKey)
    }
}
