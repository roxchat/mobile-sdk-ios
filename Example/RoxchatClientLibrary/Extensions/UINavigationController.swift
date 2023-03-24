
import UIKit

extension UINavigationController {
    
    func setTopBar(
        isEnabled: Bool,
        isTranslucent: Bool,
        barTintColor: UIColor,
        backgroundColor: UIColor) {
            
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.backgroundColor = backgroundColor
                
                navigationBar.standardAppearance = navBarAppearance
                navigationBar.compactAppearance = navBarAppearance
                navigationBar.scrollEdgeAppearance = navBarAppearance
                navigationBar.isTranslucent = isTranslucent
            } else {
                // Fallback on earlier versions
                navigationBar.barTintColor = backgroundColor
                navigationBar.isTranslucent = isTranslucent
            }
            navigationBar.tintColor = barTintColor
        }
}
