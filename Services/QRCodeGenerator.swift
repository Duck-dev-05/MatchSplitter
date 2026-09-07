import Foundation
import CoreImage.CIFilterBuiltins
import UIKit

class QRCodeGenerator {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            // Scale the image up to be sharp
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgimg = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    // Simple placeholder for generating payment payload
    func generatePaymentPayload(paymentID: String, amount: Double) -> String {
        // In a real app, this would generate EMVCo payload (e.g., PromptPay)
        // For now, it creates a readable string that could be caught by deep links
        return "PAYMENT|\(paymentID)|\(String(format: "%.2f", amount))"
    }
}
