import Foundation
import Supabase

// MARK: - Add this to your project using Swift Package Manager
// URL: https://github.com/supabase/supabase-swift
// Make sure to add the 'Supabase' library to your MatchSplitter target.

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let supabaseUrl: URL
    let supabaseKey: String
    
    let client: SupabaseClient
    
    init() {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SupabaseURL") as? String,
              let url = URL(string: urlString),
              let key = Bundle.main.object(forInfoDictionaryKey: "SupabaseKey") as? String else {
            fatalError("Supabase credentials not found in Info.plist")
        }
        
        self.supabaseUrl = url
        self.supabaseKey = key
        self.client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }
    
    // MARK: - Save Group to Supabase
    func saveGroup(_ group: Group) async throws {
        let groupData = try JSONEncoder().encode(group)
        guard let groupJsonString = String(data: groupData, encoding: .utf8) else { return }
        
        struct SupabaseGroupInsert: Codable {
            let id: UUID
            let group_data: String
            let last_updated: Date
        }
        
        let insertData = SupabaseGroupInsert(id: group.id, group_data: groupJsonString, last_updated: Date())
        
        // Upsert to handle both insert and update
        try await client
            .from("groups")
            .upsert(insertData)
            .execute()
    }
    
    // MARK: - Fetch Group from Supabase
    func fetchGroup(id: UUID) async throws -> Group? {
        struct SupabaseGroupFetch: Codable {
            let id: UUID
            let group_data: String
            let last_updated: Date
        }
        
        let response: [SupabaseGroupFetch] = try await client
            .from("groups")
            .select()
            .eq("id", value: id.uuidString)
            .execute()
            .value
        
        guard let first = response.first,
              let data = first.group_data.data(using: .utf8) else {
            return nil
        }
        
        return try JSONDecoder().decode(Group.self, from: data)
    }
    
    // MARK: - Realtime Subscriptions
    func listenForUpdates(groupId: UUID, onChange: @escaping (Group) -> Void) {
        let channel = client.channel("public:groups:id=eq.\(groupId.uuidString)")
        
        channel.on("postgres_changes", filter: .init(event: "UPDATE", schema: "public", table: "groups", filter: "id=eq.\(groupId.uuidString)")) { message in
            Task {
                if let updatedGroup = try? await self.fetchGroup(id: groupId) {
                    await MainActor.run {
                        onChange(updatedGroup)
                    }
                }
            }
        }
        
        Task {
            await channel.subscribe()
        }
    }
}
