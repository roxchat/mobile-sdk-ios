
import UIKit
import RoxchatClientLibrary

extension UIView {
    var globalPoint: CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }

    func pointInView(view: UIView) -> CGPoint {
        return self.convert(self.frame.origin, to: view)
    }
}

@objc protocol WMToolbarBackgroundViewDelegate: AnyObject {
    func showToolbarWithHeight(_ height: CGFloat)
}

class WMToolbarBackgroundView: UIView {
    @IBOutlet weak var delegate: WMToolbarBackgroundViewDelegate?
    override func layoutSubviews() {
        super.layoutSubviews()
        if let window = self.window {
            let height = window.frame.height - self.convert(self.frame.origin, to: window).y
            if height > 0 {
                self.delegate?.showToolbarWithHeight(height)
            } else {
                self.delegate?.showToolbarWithHeight(self.frame.height)
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
}
