
import UIKit
import RoxchatClientLibrary

class WMOperatorFileCell: FileMessage {
    
    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
    }
    
    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            self.sharpCorner(view: messageView, visitor: false)
        }
        return setup
    }
}
