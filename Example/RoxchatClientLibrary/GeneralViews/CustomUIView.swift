
import UIKit

class CustomUIView: UIView {
    
    // MARK: - Private properties
    private let VALUE: CGFloat =
        UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? -500.0 : 500.0
    
    // MARK: - Methods    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let bounds = self.bounds
        let frame = CGRect(
            origin: bounds.origin,
            size: CGSize(width: bounds.width + VALUE, height: bounds.height)
        )
        return frame.contains(point) ? self : nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
