
import UIKit

extension UIView {
    
    // MARK: - Methods
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
    func fadeIn(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 1 },
                       completion: { (_: Bool) in
                          if let complete = onCompletion { complete() }
                       }
        )
    }

    func fadeOut(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 0 },
                       completion: { (_: Bool) in
                           self.isHidden = true
                           if let complete = onCompletion { complete() }
                       }
        )
    }
    
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners
        } else {
            var cornerMask = UIRectCorner()
            if corners.contains(.layerMinXMinYCorner) {
                cornerMask.insert(.topLeft)
            }
            if corners.contains(.layerMaxXMinYCorner) {
                cornerMask.insert(.topRight)
            }
            if corners.contains(.layerMinXMaxYCorner) {
                cornerMask.insert(.bottomLeft)
            }
            if corners.contains(.layerMaxXMaxYCorner) {
                cornerMask.insert(.bottomRight)
            }
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: cornerMask, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    func loadViewFromNib(_ nibName: String) -> UIView {
        
        let nib = UINib(nibName: nibName, bundle: Bundle.main)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    static func loadXibView() -> Self {
        let identifier = "\(Self.self)"
        let nib = UINib(nibName: identifier, bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! Self
        view.loadXibViewSetup()
        return view
    }
    
    @objc
    func loadXibViewSetup() { }
    
    func bindWidthToSuperview() {
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superview, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
        self.superview?.addConstraint(widthConstraint)
    }
    
    func bindHeightToSuperview() {
        let heightTConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superview, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
        self.superview?.addConstraint(heightTConstraint)
    }
    
    var globalPointOnScreen: CGPoint? {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        return self.superview?.convert(self.frame.origin, to: rootView)
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
    
    func addSubviewWithSameWidth(_ subview: UIView) {
        subview.setWidth(frame.width)
        addSubview(subview)
    }
}
