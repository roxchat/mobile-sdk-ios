
import Foundation
import UIKit
import RoxchatClientLibrary

class WMVisitorMessageCell: WMMessageTableCell {
    
    @IBOutlet var messageTextView: UITextView!

    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
        
        let checkLink = self.messageTextView.setTextWithReferences(
            message.getText(),
            textColor: messageBodyLabelColourVisitor,
            alignment: .right)
        messageTextView.removeInsets()
        messageTextView.delegate = self

        if !cellMessageWasInited {
            cellMessageWasInited = true
            for recognizer in messageTextView.gestureRecognizers ?? [] {
                if recognizer.isKind(of: UITapGestureRecognizer.self) && !checkLink {
                    recognizer.delegate = self
                }
                if recognizer.isKind(of: UIPanGestureRecognizer.self) {
                    recognizer.isEnabled = false
                }
            }
            let longPressPopupGestureRecognizer = UILongPressGestureRecognizer(
                target: self,
                action: #selector(longPressAction)
            )
            longPressPopupGestureRecognizer.minimumPressDuration = 0.2
            longPressPopupGestureRecognizer.cancelsTouchesInView = false
            self.messageTextView.addGestureRecognizer(longPressPopupGestureRecognizer)
        }
    }

    override func resignTextViewFirstResponder() {
        messageTextView.resignFirstResponder()
    }
    
    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            self.sharpCorner(view: messageView, visitor: true)
        }
        return setup
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        guard textView.selectedTextRange?.isEmpty == false else { return }
        delegate?.cellChangeTextViewSelection(self)
    }
}
