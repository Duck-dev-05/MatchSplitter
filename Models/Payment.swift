import Foundation

struct Payment: Identifiable, Codable {
    var id: UUID = UUID()
    var fromUser: User
    var toUser: User
    var amount: Double
    var date: Date
}
