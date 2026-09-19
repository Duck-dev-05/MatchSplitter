import SwiftUI

struct BankLogoView: View {
    var bankID: String
    var size: CGFloat = 38
    
    var body: some View {
        if let bank = Bank.supportedBanks.first(where: { $0.id == bankID }), 
           let logoURL = bank.logoURL, 
           let url = URL(string: logoURL) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Theme.successColor.opacity(0.15))
                .frame(width: size, height: size)
            Image(systemName: "building.2.fill")
                .font(.system(size: size * 0.45, weight: .bold))
                .foregroundColor(Theme.successColor)
        }
    }
}
