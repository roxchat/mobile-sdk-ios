
import UIKit

class CustomUIButton: UIButton {
    
    // MARK: - Private properties
    private let VALUE: CGFloat = 20.0
    
    // MARK: - Methods
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(
            x: self.bounds.origin.x - VALUE / 2,
            y: self.bounds.origin.y - VALUE / 2,
            width: self.bounds.size.width + VALUE,
            height: self.bounds.size.height + VALUE
        )
        return newArea.contains(point)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
