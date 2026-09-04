import Foundation
import UIKit
import EFQRCode

struct QRGenerator {
    static func generateQRCode(from string: String, size: Int = 512) -> UIImage? {
        if let cgImage = EFQRCode.generate(
            for: string,
            size: EFIntSize(width: size, height: size),
            backgroundColor: CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            foregroundColor: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        ) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}




