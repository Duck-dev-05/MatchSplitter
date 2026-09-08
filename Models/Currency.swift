import Foundation

enum Currency: String, Codable, CaseIterable {
    case thb = "THB"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case krw = "KRW"
    
    var symbol: String {
        switch self {
        case .thb: return "฿"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .krw: return "₩"
        }
    }
}
