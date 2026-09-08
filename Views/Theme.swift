import SwiftUI

struct Theme {
    // Colors
    static let backgroundStart = Color(red: 0.06, green: 0.06, blue: 0.14)
    static let backgroundEnd = Color(red: 0.10, green: 0.08, blue: 0.22)
    static let cardBackground = Color(red: 0.14, green: 0.13, blue: 0.24)
    
    // Accents
    static let primaryAccent = Color(red: 0.43, green: 0.26, blue: 0.98)
    static let secondaryAccent = Color(red: 0.60, green: 0.20, blue: 0.85)
    
    // Light Chip Theme (From user screenshot)
    static let chipBackground = Color(red: 0.93, green: 0.87, blue: 0.85)
    static let chipText = Color(red: 0.05, green: 0.32, blue: 0.55)
    
    // Gradients
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [backgroundStart, backgroundEnd]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryAccent, secondaryAccent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // UI Helpers
    static func applyGlassCard(to view: AnyView, cornerRadius: CGFloat = 20) -> some View {
        view
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(cardBackground)
                    .shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
    }
}
