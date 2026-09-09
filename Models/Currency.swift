import Foundation

enum Currency: String, Codable, CaseIterable {
    case thb = "THB"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case krw = "KRW"
    case vnd = "VND"
    case aud = "AUD"
    case cad = "CAD"
    case sgd = "SGD"
    case inr = "INR"
    case cny = "CNY"
    case myr = "MYR"
    case idr = "IDR"
    case php = "PHP"
    
    var symbol: String {
        switch self {
        case .thb: return "฿"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .krw: return "₩"
        case .vnd: return "₫"
        case .aud: return "A$"
        case .cad: return "C$"
        case .sgd: return "S$"
        case .inr: return "₹"
        case .cny: return "¥"
        case .myr: return "RM"
        case .idr: return "Rp"
        case .php: return "₱"
        }
    }
}
