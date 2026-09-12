import Foundation

struct User {
    let id: UUID
    let name: String
}

let array = [User(id: UUID(), name: "A"), User(id: UUID(), name: "B")]
let enumerated = Array(array.enumerated())

let elementIds = enumerated.map { \.element.id }
print(elementIds)

let tupleArray: [(category: String, amount: Double)] = [("A", 1.0)]
let mapped = tupleArray.map { \.category }
print(mapped)
