
import UIKit
import RoxchatClientLibrary

class WMInfoCell: WMMessageTableCell {
    @IBOutlet var borderView: UIView!
    @IBOutlet var messageTextView: UILabel!
    
    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
        self.messageTextView.text = message.getText()
    }
    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        return setup
    }
}
