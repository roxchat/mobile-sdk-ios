
import UIKit
import Nuke
import RoxchatClientLibrary

enum WMQuoteViewMode {
    case quote
    case edit
}

protocol WMQuoteViewDelegate: AnyObject {
    func cleanTextView()
}

class WMQuoteView: UIView, URLSessionDelegate {
    @IBOutlet var quoteView: UIView!
    @IBOutlet var quoteMessageText: UILabel!
    @IBOutlet var quoteAuthorName: UILabel!
    @IBOutlet var quoteImageView: UIImageView!
    @IBOutlet var quoteLine: UIView!
    @IBOutlet var fileDownloadIndicator: CircleProgressIndicator!
    @IBOutlet var downloadStatusLabel: UILabel!
    
    weak var delegate: WMDialogCellDelegate?
    var fileSize: Int64 = 0
    var fileURL: URL?
    
    private var mode = WMQuoteViewMode.quote
    
    func currentMessage() -> String {
        return quoteMessageText.text ?? ""
    }
    
    func currentMode() -> WMQuoteViewMode {
        return mode
    }
    
    func addQuoteEditBarForMessage(_ message: Message, delegate: WMDialogCellDelegate) {
        mode = WMQuoteViewMode.edit
        self.delegate = delegate
        self.setupTextQuoteMessage(quoteText: message.getText(), quoteAuthor: String.unwarpOrEmpty(message.getSenderName()), fromOperator: message.isOperatorType())
    }
    
    func addQuoteBarForMessage(_ message: Message, delegate: WMDialogCellDelegate) {
        self.delegate = delegate
        mode = WMQuoteViewMode.quote
        if message.isText() {
            self.setupTextQuoteMessage(quoteText: message.getText(), quoteAuthor: message.getSenderName(), fromOperator: message.isOperatorType())
        } else if message.isFile() {
            guard let fileInfo = message.getData()?.getAttachment()?.getFileInfo(), let quoteState = message.getData()?.getAttachment()?.getState() else {
                return
            }
            if let imageURL = fileInfo.getImageInfo()?.getThumbURL() {
                self.setupImageQuoteMessage(quoteAuthor: message.getSenderName(), url: imageURL, fileInfo: fileInfo, fromOperator: message.isOperatorType())
            } else if let fileURL = fileInfo.getURL() {
                self.setupFileQuoteMessage(quoteText: fileInfo.getFileName(), quoteAuthor: message.getSenderName(), url: fileURL, fileInfo: fileInfo, quoteState: quoteState, openFileDelegate: delegate, fromOperator: message.isOperatorType())
            }
        }
    }
    
    func setup(_ quoteText: String, _ quoteAuthor: String, _ fromOperator: Bool) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.quoteMessageText.text = quoteText
        self.quoteAuthorName.text = quoteAuthor
        if fromOperator {
            quoteView.backgroundColor = messageBackgroundViewColourSystem
        } else {
            quoteView.backgroundColor = quoteBackgroundColor
        }
        quoteView.layer.cornerRadius = 10
        quoteMessageText.textColor = rawQuoteViewLabelColour
        if #available(iOS 11.0, *) {
            quoteView.layer.maskedCorners = [ .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
    }
    
    func setupTextQuoteMessage(quoteText: String, quoteAuthor: String, fromOperator: Bool) {
        self.setup(quoteText, quoteAuthor, fromOperator)
        self.quoteMessageText.text = quoteText
        self.quoteAuthorName.text = quoteAuthor
        self.quoteImageView.isHidden = true
        self.quoteImageView.removeConstraints(quoteImageView.constraints)
        self.quoteMessageText.leftAnchor.constraint(equalTo: self.quoteLine.rightAnchor, constant: 12.0).isActive = true
        self.quoteAuthorName.leftAnchor.constraint(equalTo: self.quoteLine.rightAnchor, constant: 12.0).isActive = true
    }
    
    func setupImageQuoteMessage(quoteAuthor: String, url: URL, fileInfo: FileInfo, fromOperator: Bool) {
        self.setup("Image".localized, quoteAuthor, fromOperator)
        self.quoteImageView.isHidden = false
        updateQuoteImageViewConstraints()
        self.quoteImageView.accessibilityIdentifier = url.absoluteString
        let request = ImageRequest(url: url)
        if let imageContainer = ImageCache.shared[request] {
            self.quoteImageView.image = imageContainer
        } else {
            WMFileDownloadManager.shared.subscribeForImage(url: url, progressListener: self)
        }
    }
    
    func setupFileQuoteMessage(quoteText: String, quoteAuthor: String, url: URL, fileInfo: FileInfo, quoteState: AttachmentState, openFileDelegate: WMDialogCellDelegate, fromOperator: Bool) {
        self.setup(quoteText, quoteAuthor, fromOperator)
        self.quoteImageView.isHidden = false
        updateQuoteImageViewConstraints()
        self.fileURL = url
        self.fileSize = fileInfo.getSize() ?? 0
        self.quoteImageView.image = UIImage(named: "FileDownloadButton")
    }
    
    override func loadXibViewSetup() {
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1)
        layer.addSublayer(topBorder)
    }
    
    @IBAction func removeQuoteEditBar() {
        if mode == .edit {
            self.delegate?.cleanTextView()
        }
        self.removeFromSuperview()
    }

    private func updateQuoteImageViewConstraints() {
        quoteMessageText.leftAnchor.constraint(equalTo: self.quoteImageView.rightAnchor, constant: 10.0).isActive = true
        quoteAuthorName.leftAnchor.constraint(equalTo: self.quoteImageView.rightAnchor, constant: 10.0).isActive = true
        quoteImageView.leftAnchor.constraint(equalTo: self.quoteLine.rightAnchor, constant: 8.0).isActive = true
        quoteImageView.heightAnchor.constraint(equalTo: self.quoteImageView.widthAnchor).isActive = true
    }
}

extension WMQuoteView: WMFileDownloadProgressListener {
    func progressChanged(url: URL, progress: Float, image: UIImage?) {
        quoteImageView.image = image ?? UIImage(named: "placeholder")
    }
}
