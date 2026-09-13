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
            let formattedAmount = String(format: "%.2f", amount)
            let cleanPaymentID = paymentID.trimmingCharacters(in: .whitespacesAndNewlines)
            return "https://paypal.me/\(cleanPaymentID)/\(formattedAmount)\(currString)"
        } else if paymentType == "Stripe" {
            let cleanPaymentID = paymentID.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleanPaymentID.hasPrefix("http") ? cleanPaymentID : "https://\(cleanPaymentID)"
        } else if paymentType == "VietQR" {
            // Very basic offline VietQR EMVCo string generator (without bin, it's just a fallback)
            let amountStr = String(format: "%.0f", amount)
            var payload = "00020101021238"
            
            let beneficiary = "0010A000000727011200069704360110\(paymentID.prefix(10))"
            payload += String(format: "%02d%@", beneficiary.count, beneficiary)
            payload += "530370454\(String(format: "%02d", amountStr.count))\(amountStr)5802VN6304"
            
            payload += crc16(payload)
            return payload
        }
        
        return "PAYMENT|\(paymentID)|\(String(format: "%.2f", amount))"
    }
    
    private func crc16(_ data: String) -> String {
        let polynomial: UInt16 = 0x1021
        var crc: UInt16 = 0xFFFF
        
        guard let dataBytes = data.data(using: .utf8) else { return "0000" }
        
        for byte in dataBytes {
            crc ^= UInt16(byte) << 8
            for _ in 0..<8 {
                if (crc & 0x8000) != 0 {
                    crc = (crc << 1) ^ polynomial
                } else {
                    crc <<= 1
                }
            }
        }
        
        return String(format: "%04X", crc)
    }
}
