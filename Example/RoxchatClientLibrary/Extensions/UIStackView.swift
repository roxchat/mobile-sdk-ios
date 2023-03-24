
import UIKit

extension UIStackView {
    
    // MARK: - Methods
    func removeAllArrangedSubviews() {
        for subView in arrangedSubviews {
            removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
    }
}
