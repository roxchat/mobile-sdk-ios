
import UIKit

extension UIImage {
    
    public func colour(_ colour: UIColor) -> UIImage {
        defer { UIGraphicsEndImageContext() }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        
        context.setBlendMode(.multiply)
        
        let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let cgImage: CGImage! = self.cgImage
        context.clip(to: rectangle, mask: cgImage)
        colour.setFill()
        context.fill(rectangle)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
