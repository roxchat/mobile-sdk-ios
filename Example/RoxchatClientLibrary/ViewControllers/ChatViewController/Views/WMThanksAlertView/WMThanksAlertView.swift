
import UIKit

class WMThanksAlertView: UIView {

    private let showAlertTime = DispatchTimeInterval.seconds(2)
    private let moveAlertAnimationTime = 0.4
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCancelGesture()
        self.alpha = 0
    }
    
    func showAlert() {
        
        DispatchQueue.main.async {
            self.present()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + showAlertTime) {
            self.hide()
        }
    }
    
    func present() {
        self.alpha = 1
        UIView.animate(withDuration: moveAlertAnimationTime) {
            self.frame = self.showRect()
        }
    }
    
    func hide() {
        UIView.animate(withDuration: moveAlertAnimationTime) {
            self.frame = self.hideRect()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + moveAlertAnimationTime) {
            self.alpha = 0
        }
        
    }
    
    func showRect() -> CGRect {
        let width = self.superview?.frame.width ?? self.frame.width
        return CGRect(x: 0, y: 0, width: width, height: self.frame.height)
    }
    
    func hideRect() -> CGRect {
        let width = self.superview?.frame.width ?? self.frame.width
        return CGRect(x: 0, y: -self.frame.height, width: width, height: self.frame.height)
    }
    
    @objc
    func hideWithoutAnimation() {
        self.frame = self.hideRect()
        self.alpha = 0
    }
    
    private func setupCancelGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hideWithoutAnimation)
        )
        self.addGestureRecognizer(tapGestureRecognizer)
    }
}
