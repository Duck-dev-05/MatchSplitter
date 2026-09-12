import Foundation
import CoreImage.CIFilterBuiltins
import UIKit
import EFQRCode

class QRCodeGenerator {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    func generateQRCode(from string: String) -> UIImage {
        // EFQRCode expects CGColor. Theme.primaryAccent is (r: 0.45, g: 0.22, b: 1.00)
        let primaryColor = UIColor(red: 0.45, green: 0.22, blue: 1.00, alpha: 1.0).cgColor
        let bgColor = UIColor.white.cgColor
        
        // Generate high-quality stylized QR code
        if let cgImage = EFQRCode.generate(
            for: string,
            backgroundColor: bgColor,
            foregroundColor: primaryColor
        ) {
            return UIImage(cgImage: cgImage)
        }
        
        // Fallback to CoreImage
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgimg = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func generatePaymentPayload(paymentType: String?, paymentID: String, amount: Double, currency: Currency? = nil) -> String {
        if paymentType == "PayPal" {
            let currString = currency?.rawValue ?? "USD"
            // Ensure no spaces in the URL
            let formattedAmount = String(format: "%.2f", amount)
            let cleanPaymentID = paymentID.trimmingCharacters(in: .whitespacesAndNewlines)
            return "https://paypal.me/\(cleanPaymentID)/\(formattedAmount)\(currString)"
        } else if paymentType == "Stripe" {
            let cleanPaymentID = paymentID.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleanPaymentID.hasPrefix("http") ? cleanPaymentID : "https://\(cleanPaymentID)"
        }
        
        // In a real app, this would generate EMVCo payload (e.g., PromptPay)
        // For now, it creates a readable string that could be caught by deep links
        return "PAYMENT|\(paymentID)|\(String(format: "%.2f", amount))"
    }
}
