import Foundation
struct MyItem: Identifiable { let id: Int }
extension Array where Element: Identifiable {
    var indexed: [Int] { return [] }
}
let a = [MyItem(id: 1)]
let b = a.indexed
