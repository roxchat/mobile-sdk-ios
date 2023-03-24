
import Foundation
import RoxchatClientLibrary
import Nuke

extension ChatViewController: WMDialogCellDelegate {
    
    func longPressAction(cell: UITableViewCell, message: Message) {
        selectedMessage = message
        shoowPopover(cell: cell, message: message, cellHeight: cell.frame.height)
    }
    func imageViewTapped(message: Message, image: UIImage?, url: URL?) {
        
        guard let url = url
        else { return }
        
        let vc = WMImageViewController.loadViewControllerFromXib()
        vc.selectedImageURL = url
        vc.selectedImage = image
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func quoteMessageTapped(message: Message?) {
        if let messageId = message?.getQuote()?.getMessageID() {
            guard let row = chatMessages.firstIndex(where: { (message) in
                message.getServerSideID() == messageId
            }) else { return }
            let indexPath = IndexPath(row: row, section: 0)
            chatTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
            UIView.animate(withDuration: 0.5, delay: 0.0, animations: {
                self.chatTableView.cellForRow(at: indexPath)?.contentView.backgroundColor = quoteBodyLabelColourVisitor
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0.2, animations: {
                    self.chatTableView.cellForRow(at: indexPath)?.contentView.backgroundColor = .clear
                })
            })
        }
    }
    
    public func openFile(message: Message?, url: URL?) {
        let vc = WMFileViewController.loadViewControllerFromXib()
        vc.fileDestinationURL = url
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func cleanTextView() {
        self.toolbarView.messageView.setMessageText("")
    }
    
    func sendKeyboardRequest(buttonInfoDictionary: [String: String]) {
        guard let messageID = buttonInfoDictionary["Message"],
            let buttonID = buttonInfoDictionary["ButtonID"],
            buttonInfoDictionary["ButtonTitle"] != nil
        else { return }
        if let message = findMessage(withID: messageID),
        let button = findButton(inMessage: message, buttonID: buttonID) {
        // TODO: Send request
        print("Sending keyboard request...")
                    
        RoxchatServiceController.currentSession.sendKeyboardRequest(
            button: button,
            message: message,
            completionHandler: self
        )
        
        } else {
            print("HALT! There isn't such message or button in #function")
        }
    }

    func cellChangeTextViewSelection(_ cell: WMMessageTableCell) {
        cellWithSelection = cell
    }
    
    private func findMessage(withID id: String) -> Message? {
        for message in chatMessages {
            if message.getID() == id {
                return message
            }
        }
        return nil
    }
    
    private func findButton(
        inMessage message: Message,
        buttonID: String
    ) -> KeyboardButton? {
        guard let buttonsArrays = message.getKeyboard()?.getButtons() else { return nil }
        let buttons = buttonsArrays.flatMap { $0 }
        
        for button in buttons {
            if button.getID() == buttonID {
                return button
            }
        }
        return nil
    }
}
