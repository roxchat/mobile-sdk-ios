
import UIKit

extension UIColor {
    
    /**
     Initializes and returns a color object using hex string.
     - parameter hexString:
     Hex string representing color with or whithout "#" prefix.
     - returns:
     The color object or `nil` if passed string can't represent a color. The color information represented by this object is in an RGB colorspace. On applications linked for iOS 10 or later, the color is specified in an extended range sRGB color space. On earlier versions of iOS, the color is specified in a device RGB colorspace.
     */
    convenience init?(hexString: String) {
        var colorString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (colorString.hasPrefix("#")) {
            colorString.remove(at: colorString.startIndex)
        }
        
        if colorString.count != 6 {
            return nil
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: colorString).scanHexInt32(&rgbValue)
        
        self.init(red: (CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0),
                  green:(CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0),
                  blue: (CGFloat(rgbValue & 0x0000FF) / 255.0),
                  alpha: 1.0)
    }
    
}
