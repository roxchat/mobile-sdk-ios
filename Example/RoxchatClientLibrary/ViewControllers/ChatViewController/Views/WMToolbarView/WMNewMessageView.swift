
import Foundation
import UIKit
import RoxchatClientLibrary

protocol WMNewMessageViewDelegate: AnyObject {
    func inputTextChanged()
    func sendMessage()
    func showSendFileMenu(_ sender: UIButton)
}

class WMNewMessageView: UIView {
    
    static let maxInputTextViewHeight: CGFloat = 90
    static let minInputTextViewHeight: CGFloat = 344
    
    weak var delegate: WMNewMessageViewDelegate?
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet private var fileButton: UIButton!
    @IBOutlet private var messagePlaceholder: UILabel!
    @IBOutlet var messageText: UITextView!
    
    @IBOutlet private var inputTextFieldConstraint: NSLayoutConstraint!
    
    func resignMessageViewFirstResponder() {
        self.messageText.resignFirstResponder()
    }
    
    func getMessage() -> String {
        return self.messageText.text
    }
    
    func setMessageText(_ message: String) {
        self.messageText.text = message
        // Workaround to trigger textViewDidChange
        self.messageText.replace(
            self.messageText.textRange(
                from: self.messageText.beginningOfDocument,
                to: self.messageText.endOfDocument) ?? UITextRange(),
            withText: message
        )
        recountViewHeight()
    }
    
    func recountViewHeight() {
        let size = messageText.sizeThatFits(CGSize(width: messageText.frame.width, height: CGFloat(MAXFLOAT)))
        inputTextFieldConstraint.constant = min(size.height, WMNewMessageView.maxInputTextViewHeight)
    }
    
    override func loadXibViewSetup() {
        messageText.layer.cornerRadius = 17
        messageText.layer.borderWidth = 1
        messageText.layer.borderColor = wmGreyMessage
        messageText.isScrollEnabled = true
        messageText.textColor = .black
        messageText.contentInset.left = 10
        messageText.textContainerInset.right = 40
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height), height: 1)
        topBorder.backgroundColor = wmGreyMessage
        layer.addSublayer(topBorder)
        messageText.delegate = self

        translatesAutoresizingMaskIntoConstraints = false
        recountViewHeight()
    }
    
    var textInputTextViewBufferString: String?
    var alreadyPutTextFromBufferString = false
    
    @IBAction func sendMessage() {
        self.delegate?.sendMessage()
    }
    
    @IBAction func sendFile(_ sender: UIButton) {
        self.delegate?.showSendFileMenu(sender)
    }
    
    func insertText(_ text: String) {
        self.messageText.replace(self.messageText.selectedRange.toTextRange(textInput: self.messageText)!, withText: text)
    }
}

extension WMNewMessageView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        showHidePlaceholder(in: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        recountViewHeight()
        showHidePlaceholder(in: textView)
        self.delegate?.inputTextChanged()
    }
    
    func showHidePlaceholder(in textView: UITextView) {
        let check = textView.hasText && !textView.text.isEmpty
        messageText.layer.borderColor = check ? wmLayerColor : wmGreyMessage
        messagePlaceholder.isHidden = check
        sendButton.isEnabled = check
    }
}
