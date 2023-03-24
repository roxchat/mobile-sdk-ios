
import Foundation
import RoxchatClientLibrary
import UIKit

class WMBotButtonsTableViewCell: WMMessageTableCell {
    
    @IBOutlet var borderView: UIView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var messageTextView: UITextView!
    private let SPACING_CELL: CGFloat = 6.0
    private let SPACING_DEFAULT: CGFloat = 10.0
    
    
    lazy var buttonsVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .trailing
        stackView.distribution = .fill
        stackView.spacing = SPACING_CELL
        return stackView
    }()
    
    private func emptyTheCell() {
        buttonsVerticalStack.removeFromSuperview()
        buttonsVerticalStack.removeAllArrangedSubviews()
        self.messageView.isHidden = true
        self.messageTextView.text = ""
        self.buttonView.isHidden = false
    }
    
    override func setMessage(message: Message, tableView: UITableView) {
        emptyTheCell()
        self.messageView.alpha = 0
        self.buttonView.alpha = 1
        self.message = message
        buttonView.addSubview(buttonsVerticalStack)
        fillButtonsCell(message: message, showFullDate: true)
    }
    
    private func fillButtonsCell(
        message: Message,
        showFullDate: Bool
    ) {
        guard let keyboard = message.getKeyboard() else { return }
        let buttonsArray = keyboard.getButtons()
        var isActive = false
        self.time.isHidden = true
        
        switch keyboard.getState() {
        case .pending:
            isActive = true
        case .canceled:
            isActive = false
        case .completed:
            isActive = false
            buttonWasSelected()
            self.messageView.alpha = 1
            return
        }
        
        for buttonsStack in buttonsArray {
            for button in buttonsStack {
                let uiButton = UIButton(type: .system),
                    buttonID = button.getID(),
                    buttonText = button.getText()
                
                uiButton.accessibilityIdentifier = buttonID
                
                uiButton.setTitle(buttonText, for: .normal)
                uiButton.isUserInteractionEnabled = isActive
                /// add buttons only with text
                guard let titleLabel = uiButton.titleLabel else {
                    continue
                }
                titleLabel.font = UIFont.systemFont(ofSize: 13.0)
                titleLabel.textAlignment = .center
                titleLabel.lineBreakMode = .byWordWrapping
                titleLabel.numberOfLines = 0
                /// button text insets
                titleLabel.snp.remakeConstraints { make in
                    make.top.equalToSuperview().inset(10)
                    make.height.greaterThanOrEqualTo(18)
                    make.width.lessThanOrEqualToSuperview().inset(10)
                }
                
                uiButton.layer.borderWidth = 1
                uiButton.layer.borderColor = buttonBorderColor.cgColor
                uiButton.clipsToBounds = true
                uiButton.translatesAutoresizingMaskIntoConstraints = false
                uiButton.layer.cornerRadius = 20
                if isActive {
                    uiButton.addTarget(
                        self,
                        action: #selector(sendButton),
                        for: .touchUpInside
                    )
                }
                
                if isActive {
                    // set default buttons
                    uiButton.backgroundColor = buttonDefaultBackgroundColour
                    uiButton.tintColor = buttonDefaultTitleColour
                } else {
                    uiButton.backgroundColor = buttonCanceledBackgroundColour
                    uiButton.tintColor = buttonCanceledTitleColour
                }
                
                buttonsVerticalStack.addArrangedSubview(uiButton)
                uiButton.snp.remakeConstraints { make in
                    make.trailing.equalToSuperview()
                }
                buttonsVerticalStack.sizeToFit()
            }
        }
        cellLayoutConstraintButtons(showFullDate: showFullDate)
    }
    
    private func cellLayoutConstraintButtons(showFullDate: Bool) {
        buttonsVerticalStack.snp.remakeConstraints { (make) -> Void in
            make.top.equalToSuperview()
                .inset(SPACING_DEFAULT)
            make.trailing.leading.equalToSuperview()
            make.height.lessThanOrEqualToSuperview().inset(10)
        }
        buttonsVerticalStack.sizeToFit()
    }
    
    private func buttonWasSelected() {
        guard let keyboard = message.getKeyboard() else { return }
        self.emptyTheCell()
        let buttonsArray = keyboard.getButtons()
        let response = keyboard.getResponse()
        for buttonsStack in buttonsArray {
            for button in buttonsStack {
                if button.getID() == response?.getButtonID() {
                    messageTextView.text = button.getText()
                    let timeString = WMMessageTableCell.timeFormatter.string(from: message.getTime())
                    self.time.text = timeString
                }
            }
        }
        self.sharpCorner(view: messageView, visitor: true)
        self.messageTextView.sizeToFit()
        self.messageView.sizeToFit()
        self.borderView.sizeToFit()
        self.messageView.isHidden = false
        self.time.isHidden = false
        self.buttonView.isHidden = true
    }
    
    @objc
    private func sendButton(sender: UIButton) {
        let messageID = message.getID()
        guard let title = sender.titleLabel?.text,
              let id = sender.accessibilityIdentifier
        else { return }
        sender.backgroundColor = buttonChoosenBackgroundColour
        sender.tintColor = buttonChoosenTitleColour
        print("Buttton \(title) with tag\\ID \(id) of message \(messageID) was tapped!")
        let buttonInfoDictionary = [
            "Message": messageID,
            "ButtonID": id,
            "ButtonTitle": title
        ]
        sendKeyboardRequest(keyboardRequest: buttonInfoDictionary)
        
        UIView.animate(withDuration: 1,
                       animations: { [weak self] in
            self?.messageView.alpha = 1
            self?.buttonView.alpha = 0
        }, completion: { (finished: Bool) in
            self.buttonWasSelected()
        })
    }
}
