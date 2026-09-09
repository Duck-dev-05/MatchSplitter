import SwiftUI

struct ChipView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(Color(red: 0.05, green: 0.32, blue: 0.55)) // Dark blue text
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(red: 0.93, green: 0.87, blue: 0.85)) // Light beige/gray background
            .clipShape(Capsule())
    }
}

