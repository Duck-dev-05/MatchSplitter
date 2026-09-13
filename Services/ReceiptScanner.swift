import SwiftUI
import Vision

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .camera
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Receipt Scanner
class ReceiptScanner {
    static let shared = ReceiptScanner()
    private init() {}

    /// Scans the image for text and attempts to find a total amount.
    func scanForTotalAmount(in image: UIImage) async throws -> Double? {
        guard let cgImage = image.cgImage else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: nil)
                    return
                }

                var recognizedStrings = [String]()
                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    recognizedStrings.append(topCandidate.string)
                }

                let total = self.extractTotal(from: recognizedStrings)
                continuation.resume(returning: total)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func extractTotal(from textLines: [String]) -> Double? {
        let keywords = ["total", "amount due", "balance", "thanh toan", "tong cong"]
        let pattern = "(\\d{1,3}([, ]\\d{3})*([.,]\\d{2})?|\\d+([.,]\\d{2})?)"
        let regex = try? NSRegularExpression(pattern: pattern)
        
        var foundKeyword = false
        var possibleAmounts = [Double]()
        
        for line in textLines {
            let lowerLine = line.lowercased()
            
            // Check for keywords
            if keywords.contains(where: { lowerLine.contains($0) }) {
                foundKeyword = true
            }
            
            if let regex = regex {
                let nsString = line as NSString
                let results = regex.matches(in: line, range: NSRange(location: 0, length: nsString.length))
                
                for result in results {
                    let match = nsString.substring(with: result.range)
                    let clean = match.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: " ", with: "")
                    if let val = Double(clean) {
                        if foundKeyword {
                            return val // Return the first number found after or on the same line as a keyword
                        }
                        possibleAmounts.append(val)
                    }
                }
            }
        }

        // Fallback to absolute maximum value found if no keywords matched
        return possibleAmounts.max()
    }
}
