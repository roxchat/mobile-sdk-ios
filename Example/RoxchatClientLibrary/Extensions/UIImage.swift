
import UIKit

extension UIImage {
    public enum FlipOrientation {
        case vertically, horizontally
    }
    
    public func flipImage(_ orientation: FlipOrientation) -> UIImage {
        defer { UIGraphicsEndImageContext() }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.translateBy(x: size.width / 2, y: size.height / 2)
        
        switch orientation {
        case .horizontally:
            context.scaleBy(x: -1.0, y: -1.0)
        case .vertically:
            context.scaleBy(x: -1.0, y: 1.0)
        }
        
        context.translateBy(x: -size.width / 2, y: -size.height / 2)
        let cgImage: CGImage! = self.cgImage
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
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
