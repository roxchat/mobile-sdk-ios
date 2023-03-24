
import UIKit

class WMSaveView: UIView {
    
    @IBOutlet var circleView: UIView!
    @IBOutlet var checkmark: CheckmarkView!
    
    override func loadXibViewSetup() {
        self.layer.cornerRadius = 10
        circleView.layer.cornerRadius = 20
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = roxchatCyan
        self.alpha = 0
    }
    
    func animateImage() {
        WMSaveView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }){ _ in
            self.checkmark.animateCheckmark()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                WMSaveView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.alpha = 0
                }){ _ in
                    self.removeFromSuperview()
                }
            }
        }
    }
}


class CheckmarkView: UIView {
    
    @objc override dynamic class var layerClass: AnyClass {
        get { return CAShapeLayer.self }
    }
    
    public func animateCheckmark() {
        setupLayer()
        guard let layer = layer as? CAShapeLayer else { return }
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        layer.add(animation, forKey: nil)
        DispatchQueue.main.async {
            layer.strokeEnd = 1.0
        }
    }

    func setupLayer() {
        guard let layer = layer as? CAShapeLayer else { return }
        layer.lineWidth = 2
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = roxchatCyan
        layer.strokeEnd = 0.0
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 10, y: bounds.midY))
        path.addLine(to: CGPoint(x: 19, y: bounds.midY + 8))
        path.addLine(to: CGPoint(x: 31, y: bounds.midY - 8))
        layer.path = path.cgPath
    }
}
