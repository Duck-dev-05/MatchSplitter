import Foundation

class LocalCacheService {
    static let shared = LocalCacheService()
    private let fileManager = FileManager.default
    
    private init() {}
    
    private func getDocumentURL(for filename: String) -> URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(filename)
    }
    
    func saveGroups(_ groups: [Group]) {
        let url = getDocumentURL(for: "groups_cache.json")
        if let data = try? JSONEncoder().encode(groups) {
            try? data.write(to: url)
        }
    }
    
    func loadGroups() -> [Group] {
        let url = getDocumentURL(for: "groups_cache.json")
        if let data = try? Data(contentsOf: url),
           let groups = try? JSONDecoder().decode([Group].self, from: data) {
            return groups
        }
        return []
    }
}
