
import UIKit
import RoxchatClientLibrary

protocol WMDialogCellDelegate: AnyObject {
    func quoteMessageTapped(message: Message?)
    func imageViewTapped(message: Message, image: UIImage?, url: URL?)
    func openFile(message: Message?, url: URL?)
    func longPressAction(cell: UITableViewCell, message: Message)
    func cleanTextView()
    func sendKeyboardRequest(buttonInfoDictionary: [String: String])
    func cellChangeTextViewSelection(_ cell: WMMessageTableCell)
}

class WMMessageTableCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet var time: UILabel!
    private var cellWasInited = false
    var cellMessageWasInited = false
    
    @IBOutlet var messageView: UIView!
    
    // operator
    @IBOutlet var authorName: UILabel?
    // visitor
    @IBOutlet var sendStatus: UIImageView?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?
    
    // quote
    @IBOutlet var quoteView: UIView?
    
    weak var delegate: WMDialogCellDelegate?
    var message: Message!
    weak var tableView: UITableView?
    
    static let timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    func setMessage(message: Message, tableView: UITableView) {
        self.message = message
        self.tableView = tableView
        let timeString = WMMessageTableCell.timeFormatter.string(from: message.getTime())
        let time: String
        if message.isEdited() {
            time = "edited".localized + " " + timeString
        } else {
            time = timeString
        }
        self.time.text = time
        self.authorName?.text = message.getSenderName()
        self.updateStatus(sendStatus: message.getSendStatus() == .sent, readStatus: message.isReadByOperator())
    }
    
    func getMessage() -> Message? {
        return self.message
    }
    
    func initialSetup() -> Bool {
        
        if !cellWasInited {
            //self.transform = CGAffineTransform(scaleX: 1, y: -1)
            self.cellWasInited = true
            
            let longPressPopupGestureRecognizer = UILongPressGestureRecognizer(
                target: self,
                action: #selector(longPressAction)
            )
            longPressPopupGestureRecognizer.minimumPressDuration = 0.2
            longPressPopupGestureRecognizer.cancelsTouchesInView = false
            self.gestureRecognizers = nil
            self.addGestureRecognizer(longPressPopupGestureRecognizer)
            // quote view init
            if quoteView != nil {
                let tapGestureRecognizer = UITapGestureRecognizer(
                    target: self,
                    action: #selector(quoteViewTapped)
                )
                self.quoteView?.gestureRecognizers = nil
                self.quoteView?.addGestureRecognizer(tapGestureRecognizer)
                
                self.quoteView?.layer.cornerRadius = 10
                //            self.quoteView.layer.maskedCorners = [ .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            }
            return true
        }
        return false
    }
    
    func sharpCorner(view: UIView?, visitor: Bool) {
        if !visitor {
            view?.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 10)
        } else {
            view?.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 10)
        }
    }
    
    func updateStatus(sendStatus: Bool, readStatus: Bool) {
        if sendStatus {
            activityIndicatorView?.stopAnimating()
            activityIndicatorView?.isHidden = true
        } else {
            activityIndicatorView?.startAnimating()
            activityIndicatorView?.isHidden = false
        }
        
        self.sendStatus?.isHidden = !sendStatus
        if readStatus {
            self.sendStatus?.image = UIImage(named: "ReadByOperator")
        } else {
            self.sendStatus?.image = UIImage(named: "Sent")
        }
    }

    func resignTextViewFirstResponder() {}
    
    @objc func longPressAction(sender: UILongPressGestureRecognizer) {
        self.delegate?.longPressAction(cell: self, message: self.message)
    }
    
    @objc func quoteViewTapped() {
        self.delegate?.quoteMessageTapped(message: self.message)
    }
    
    @objc func sendKeyboardRequest(keyboardRequest: [String: String]) {
        self.delegate?.sendKeyboardRequest(buttonInfoDictionary: keyboardRequest)
    }
}
