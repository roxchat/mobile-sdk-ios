
import UIKit
import RoxchatClientLibrary

class WMQuoteImageCell: WMMessageTableCell, WMFileDownloadProgressListener {
    
    @IBOutlet var messageTextView: UITextView!
    
    @IBOutlet var quoteMessageText: UILabel!
    @IBOutlet var quoteAuthorName: UILabel!
    
    @IBOutlet var quoteImage: UIImageView!
    var url: URL?

    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
        self.quoteImage.image = UIImage(named: "placeholder")
        self.quoteMessageText.text = "Image".localized
        self.quoteAuthorName.text = message.getQuote()?.getSenderName()
        
        if let imageURL = message.getQuote()?.getMessageAttachment()?.getImageInfo()?.getThumbURL() {
            self.url = imageURL
            WMFileDownloadManager.shared.subscribeForImage(url: imageURL, progressListener: self)
        }
        
        let checkLink = self.messageTextView.setTextWithReferences(message.getText(), alignment: .left)
        for recognizer in messageTextView.gestureRecognizers ?? [] {
            if recognizer.isKind(of: UITapGestureRecognizer.self) && !checkLink {
                recognizer.delegate = self
            }
            if recognizer.isKind(of: UIPanGestureRecognizer.self) {
                recognizer.isEnabled = false
            }
        }
    }
    
    func progressChanged(url: URL, progress: Float, image: UIImage?) {
        if url != self.url {
            return
        }
        if let image = image {
            self.quoteImage.image = image
        } else {
            self.quoteImage.image = UIImage(named: "placeholder")
        }
    }
    
    @objc func imageViewTapped() {
        self.delegate?.imageViewTapped(message: self.message, image: self.quoteImage.image, url: self.url)
    }

    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            let imageTapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(imageViewTapped)
            )

            self.sharpCorner(view: messageView, visitor: true)
            self.quoteImage.gestureRecognizers = nil
            self.quoteImage.addGestureRecognizer(imageTapGestureRecognizer)
        }
        return setup
    }
}

class TextMessage: WMMessageTableCell {
    @IBOutlet var messageLabel: UILabel!
}
