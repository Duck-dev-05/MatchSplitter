import Foundation
import UIKit
import CoreImage.CIFilterBuiltins

struct QRGenerator {
    static func generateQRCode(from string: String, size: Int = 512) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            // Scale the image to be larger so it's not blurry
            let scaleX = CGFloat(size) / outputImage.extent.size.width
            let scaleY = CGFloat(size) / outputImage.extent.size.height
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
