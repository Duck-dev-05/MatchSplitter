import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("selectedAppTheme") var selectedTheme: AppTheme = .dark
    
    var colorScheme: ColorScheme? {
        selectedTheme.colorScheme
    }
}
