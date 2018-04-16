import Foundation
import UIKit

final class ReSearchResults: ComponentManager {
    var searchResults: SearchResults?
    var didRenderView: Bool = false

    override init(controller: UIViewController) {
        super.init(controller: controller)
        initialFrame()
        renderSearchResults()
        registerNotification()
        swipeUpPanGesture()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Notification Observer
    private func registerNotification() {
        NotificationCenter.default.addObserver(forName: Notification.UpdateSearchResults, object: nil, queue: .main) { [weak self] _ in
            DispatchQueue.main.async {
                let newHeight = Layout.height * 0.065 * CGFloat(store.addressSuggestions.count)
                self?.frame.size.height = newHeight
                self?.searchResults?.frame.size.height = newHeight
                self?.searchResults?.reloadData()
            }
        }

        NotificationCenter.default.addObserver(forName: Notification.DismissSearchResults, object: nil, queue: .main) { [weak self] _ in
            DispatchQueue.main.async {
                let newHeight = CGFloat(integerLiteral: 0)
                self?.frame.size.height = newHeight
                self?.searchResults?.frame.size.height = newHeight
            }
        }
    }

    // MARK: Animation
    private func swipeUpPanGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector (handleGesture))
        addGestureRecognizer(gesture)
    }

    @objc private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
        case .changed:
            if translation.y < 0.13 * 1.65 {
                DispatchQueue.main.async {
                    self.frame.origin.y = (Layout.height * 0.13 * 1.65) + translation.y

//                    if (translation.y < 0.0) {
//                        self.alpha = ((translation.y * -1) / -50) / self.frame.size.height
//                    }
                }
            }
        case .ended:
            if translation.y < -(frame.size.height / 5) {
                UIView.animate(withDuration: 1) {
                    self.frame.origin.y = (Layout.height * 0.08)
                    self.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.frame.origin.y = (Layout.height * 0.13 * 1.65)
                }
            }
            break
        default: break
        }
    }

    // MARK: Private Component Rendering
    private func renderSearchResults() {
        let view = SearchResults(frame: bounds)
        searchResults = view
        addSubview(view)
    }

    // MARK: Private Superview Framing
    private func initialFrame() {
        self.frame.size.width = Layout.width * 0.90
        self.frame.origin.y = (Layout.height * 0.13) * 1.65
        self.center.x = Position.centerX
    }
}

