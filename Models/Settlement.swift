import Foundation

struct Settlement: Identifiable, Hashable {
    var id: UUID = UUID()
    var fromUser: User
    var toUser: User
    var amount: Double
}
