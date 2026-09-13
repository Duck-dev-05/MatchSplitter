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
        // Very basic heuristic: Look for lines containing "Total", "TOTAL", "Total Amount"
        // and extract the largest currency-looking number near it or globally if not found explicitly.
        
        var possibleAmounts = [Double]()
        
        // Regex to match typical price formats (e.g. 1,234.56 or 1234,56 or 1234)
        // This is a naive regex for matching amounts
        let pattern = "(\\d{1,3}([, ]\\d{3})*([.,]\\d{2})?|\\d+([.,]\\d{2})?)"
        let regex = try? NSRegularExpression(pattern: pattern)

        for line in textLines {
            let lowerLine = line.lowercased()
            // Extract all numbers
            if let regex = regex {
                let nsString = line as NSString
                let results = regex.matches(in: line, range: NSRange(location: 0, length: nsString.length))
                
                for result in results {
                    let match = nsString.substring(with: result.range)
                    // Clean up the match to cast to double
                    let clean = match.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: " ", with: "")
                    if let val = Double(clean) {
                        possibleAmounts.append(val)
                    }
                }
            }
        }

        // Return the absolute maximum value found as a heuristic for "Total"
        return possibleAmounts.max()
    }
}
