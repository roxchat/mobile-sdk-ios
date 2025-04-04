
import UIKit

extension UIView {
    static func loadXibView() -> Self {
        let identifier = "\(Self.self)"
        let nib = UINib(nibName: identifier, bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! Self
        view.loadXibViewSetup()
        return view
    }
    
    @objc
    func loadXibViewSetup() { }

    func loadViewFromNib(_ nibName: String) -> UIView {
        let nib = UINib(nibName: nibName, bundle: Bundle.main)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func setWidth(_ width: CGFloat) {
        var newFrame = frame
        newFrame.size.width = width
        self.frame = newFrame
    }
    
    func setHeight(_ height: CGFloat) {
        var newFrame = frame
        newFrame.size.height = height
        self.frame = newFrame
    }
}
