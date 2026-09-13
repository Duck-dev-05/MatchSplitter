import Foundation
import CloudKit
import UserNotifications

class CloudKitManager {
    static let shared = CloudKitManager()
    
    let container = CKContainer.default()
    let publicDB: CKDatabase
    
    init() {
        self.publicDB = container.publicCloudDatabase
    }
    
    // MARK: - Save Group to CloudKit
    func saveGroup(_ group: Group) async throws {
        let recordId = CKRecord.ID(recordName: group.id.uuidString)
        let record = CKRecord(recordType: "MatchSplitterGroup", recordID: recordId)
        
        let data = try JSONEncoder().encode(group)
        record["groupData"] = String(data: data, encoding: .utf8) as CKRecordValue?
        record["lastUpdated"] = Date() as CKRecordValue
        
        do {
            let _ = try await publicDB.save(record)
        } catch let error as CKError {
            if error.code == .serverRecordChanged {
                // Ignore merge conflicts for now, just force overwrite by fetching and updating
                if let existing = try? await publicDB.record(for: recordId) {
                    existing["groupData"] = String(data: data, encoding: .utf8) as CKRecordValue?
                    existing["lastUpdated"] = Date() as CKRecordValue
                    let _ = try? await publicDB.save(existing)
                }
            } else {
                throw error
            }
        }
    }
    
    // MARK: - Fetch Group from CloudKit
    func fetchGroup(id: UUID) async throws -> Group? {
        let recordId = CKRecord.ID(recordName: id.uuidString)
        do {
            let record = try await publicDB.record(for: recordId)
            if let jsonString = record["groupData"] as? String,
               let data = jsonString.data(using: .utf8) {
                let group = try JSONDecoder().decode(Group.self, from: data)
                return group
            }
        } catch let error as CKError where error.code == .unknownItem {
            return nil
        }
        return nil
    }
    
    // MARK: - Subscriptions (Push Notifications)
    func setupSubscriptions() {
        let subscriptionId = "group-updates"
        
        // Setup push notification subscription for any updates to MatchSplitterGroup
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: "MatchSplitterGroup", predicate: predicate, subscriptionID: subscriptionId, options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "A group you're in has been updated!"
        notificationInfo.soundName = "default"
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { result, error in
            if let error = error {
                print("Failed to save CloudKit subscription: \(error.localizedDescription)")
            } else {
                print("Successfully subscribed to CloudKit updates.")
            }
        }
    }
    
    func requestPushNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    #if os(iOS)
                    // Request registration on main thread
                    UIApplication.shared.registerForRemoteNotifications()
                    #endif
                }
            }
        }
    }
}
