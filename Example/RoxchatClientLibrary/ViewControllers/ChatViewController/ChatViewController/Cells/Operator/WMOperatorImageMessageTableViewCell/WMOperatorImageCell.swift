
import UIKit
import RoxchatClientLibrary

class WMOperatorImageCell: WMImageTableViewCell {

    @IBOutlet var gradientView: UIView!
    private var gradientLayer = CAGradientLayer()
    
    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
    }

    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            self.sharpCorner(view: messageView, visitor: false)
            self.downloadProcessIndicator.setDefaultSetup()
            setGradientBackground()
        }
        return setup
    }
    func setGradientBackground() {
        gradientLayer.colors = [
          UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor,
          UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        gradientLayer.bounds = imagePreview.bounds.insetBy(dx: 35, dy: -0.5 * imagePreview.bounds.size.height)
        gradientLayer.position = gradientView.center
        self.imagePreview.layer.addSublayer(gradientLayer)
    }
}
