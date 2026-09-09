import Foundation

struct AppData: Codable {
    var groups: [Group]
    var currentUser: User?
    var registeredUsers: [User]?
    var defaultCurrency: Currency
}

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let fileName = "MatchSplitterData.json"
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    func save(appData: AppData) {
        do {
            let data = try JSONEncoder().encode(appData)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            print("Data successfully saved to \(fileURL.path)")
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
    
    func load() -> AppData? {
        do {
            let data = try Data(contentsOf: fileURL)
            let appData = try JSONDecoder().decode(AppData.self, from: data)
            print("Data successfully loaded from \(fileURL.path)")
            return appData
        } catch {
            print("Failed to load data (or no data exists yet): \(error.localizedDescription)")
            return nil
        }
    }
}
