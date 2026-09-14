import SwiftUI

class SnapshotHelper {
    static func takeSnapshot<V: View>(of view: V, size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: view.edgesIgnoringSafeArea(.all))
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
