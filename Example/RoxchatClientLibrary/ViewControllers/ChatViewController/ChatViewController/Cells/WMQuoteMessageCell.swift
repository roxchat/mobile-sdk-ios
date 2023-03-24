
import UIKit
import RoxchatClientLibrary

class WMQuoteMessageCell: WMMessageTableCell {
    
    @IBOutlet var quoteMessageText: UILabel!
    @IBOutlet var quoteAuthorName: UILabel!
    
    @IBOutlet var messageTextView: UITextView!
    
    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
        
        self.quoteMessageText.text = message.getQuote()?.getMessageText()
        self.quoteAuthorName.text = message.getQuote()?.getSenderName()
        let checkLink = self.messageTextView.setTextWithReferences(message.getText(), alignment: .left)
        self.messageTextView.isUserInteractionEnabled = true
        for recognizer in messageTextView.gestureRecognizers ?? [] {
            if recognizer.isKind(of: UITapGestureRecognizer.self) && !checkLink {
                recognizer.delegate = self
            }
            if recognizer.isKind(of: UIPanGestureRecognizer.self) {
                recognizer.isEnabled = false
            }
        }
    }
        
}
