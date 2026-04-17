import SwiftUI
import UIKit

enum KeyboardDismiss {
    static func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Installs a window-level tap that ends editing, without stealing taps from text views / fields.
struct DismissKeyboardOnTapOutside: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.ensureGesture(on: uiView.window)
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.teardown()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private let gesture = UITapGestureRecognizer()
        private weak var window: UIWindow?

        func ensureGesture(on newWindow: UIWindow?) {
            guard let newWindow else { return }
            if window === newWindow { return }
            if let w = window {
                w.removeGestureRecognizer(gesture)
            }
            gesture.removeTarget(nil, action: nil)
            gesture.addTarget(self, action: #selector(handleTap))
            gesture.delegate = self
            gesture.cancelsTouchesInView = false
            newWindow.addGestureRecognizer(gesture)
            window = newWindow
        }

        func teardown() {
            gesture.removeTarget(nil, action: nil)
            gesture.delegate = nil
            if let w = window {
                w.removeGestureRecognizer(gesture)
            }
            window = nil
        }

        @objc private func handleTap() {
            KeyboardDismiss.dismiss()
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            var v: UIView? = touch.view
            while let view = v {
                if view is UITextView || view is UITextField { return false }
                v = view.superview
            }
            return true
        }
    }
}
