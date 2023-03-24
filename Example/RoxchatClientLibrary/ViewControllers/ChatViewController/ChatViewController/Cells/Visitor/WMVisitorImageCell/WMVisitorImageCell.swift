
import UIKit
import RoxchatClientLibrary

class WMVisitorImageCell: WMImageTableViewCell {
    
    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
    }
    
    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            self.sharpCorner(view: imagePreview, visitor: true)
            self.sharpCorner(view: messageView, visitor: true)
            self.downloadProcessIndicator.setDefaultSetup()
        }
        return setup
    }
}
