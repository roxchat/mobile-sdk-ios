
import UIKit
import RoxchatClientLibrary

class WMQuoteFileCell: FileMessage {
    @IBOutlet var messageTextView: UITextView!
    
    @IBOutlet var quoteAuthorName: UILabel!
    @IBOutlet var quoteMessageText: UILabel!
    
    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
        
        self.isForOperator = true
        var fileSize: Int64 = -1
        
        if let attachment = message.getQuote()?.getMessageAttachment(),
           let fileURL = attachment.getURL() {
            fileSize = attachment.getSize() ?? -1
            self.documentDownloadTask = WMDocumentDownloadTask.documentDownloadTaskFor(url: fileURL, fileSize: fileSize, delegate: self)
        }
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
        self.quoteMessageText.text = message.getData()?.getAttachment()?.getFileInfo().getFileName()
        self.fileDownloadIndicator?.isHidden = true
        self.downloadStatusLabel?.text = ""
    
        self.quoteMessageText?.text = FileMessage.byteCountFormatter.string(fromByteCount: fileSize)
        
        // case sent
        
        switch message.getSendStatus() {
        case .sent:
            resetFileStatus()
        case .sending:
            self.fileDescription?.text = "Sending".localized
            self.fileStatus.setBackgroundImage( UIImage(named: "FileDownloadButton")!, for: .normal )
            self.fileStatus.isUserInteractionEnabled = false
        }
    }
    
}
