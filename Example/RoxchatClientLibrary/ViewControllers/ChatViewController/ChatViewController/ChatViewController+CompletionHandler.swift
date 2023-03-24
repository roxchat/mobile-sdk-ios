
import Foundation
import RoxchatClientLibrary

extension ChatViewController: SendFileCompletionHandler,
                              EditMessageCompletionHandler,
                              DeleteMessageCompletionHandler,
                              SendKeyboardRequestCompletionHandler,
                              ReactionCompletionHandler {
    
    // MARK: - Methods
    
    func onSuccess(messageID: String) {
        // Ignored.
        // Delete visitor typing draft after message is sent.
        RoxchatServiceController.currentSession.setVisitorTyping(draft: nil)
    }
    
    // SendFileCompletionHandler
    func onFailure(messageID: String, error: SendFileError) {
        DispatchQueue.main.async {
            var message = "Find sending unknown error".localized
            switch error {
            case .fileSizeExceeded:
                message = "File is too large.".localized
            case .fileTypeNotAllowed:
                message = "File type is not supported".localized
            case .unknown:
                message = "Find sending unknown error".localized
            case .uploadedFileNotFound:
                message = "Sending files in body is not supported".localized
            case .unauthorized:
                message = "Failed to upload file: visitor is not logged in".localized
            case .maxFilesCountPerChatExceeded:
                message = "MaxFilesCountExceeded".localized
            case .fileSizeTooSmall:
                message = "File is too small".localized
            }
            
            self.alertOnFailure(
                with: message,
                id: messageID,
                title: "File sending failed".localized
            )
        }
    }
    
    // EditMessageCompletionHandler
    func onFailure(messageID: String, error: EditMessageError) {
        DispatchQueue.main.async {
            var message = "Edit message unknown error".localized
            switch error {
            case .unknown:
                message = "Edit message unknown error".localized
            case .notAllowed:
                message = "Editing messages is turned off on the server".localized
            case .messageEmpty:
                message = "Editing message is empty".localized
            case .messageNotOwned:
                message = "Message not owned by visitor".localized
            case .maxLengthExceeded:
                message = "MaxMessageLengthExceeded".localized
            case .wrongMesageKind:
                message = "Wrong message kind (not text)".localized
            }
            
            self.alertOnFailure(
                with: message,
                id: messageID,
                title: "Message editing failed".localized
            )
        }
    }
    
    // DeleteMessageCompletionHandler
    func onFailure(messageID: String, error: DeleteMessageError) {
        DispatchQueue.main.async {
            var message = "Delete message unknown error".localized
            switch error {
            case .unknown:
                message = "Delete message unknown error".localized
            case .notAllowed:
                message = "Deleting messages is turned off on the server".localized
            case .messageNotOwned:
                message = "Message not owned by visitor".localized
            case .messageNotFound:
                message = "Message not found".localized
            }
            
            self.alertOnFailure(
                with: message,
                id: messageID,
                title: "Message deleting failed".localized
            )
        }
    }
    
    // ReacionCompletionHandler
    func onFailure(error: ReactionError) {
        DispatchQueue.main.async {
            var message = "Unknown error"
            switch error {
            case .unknown:
                message = "Unknown error"
            case .notAllowed:
                message = "Reaction not allowed"
            case .messageNotOwned:
                message = "Message not owned"
            case .messageNotFound:
                message = "Message not found"
            }
            self.alertOnFailure(
                with: message,
                id: "",
                title: "Error"
            )
        }
    }
    
    // SendKeyboardRequestCompletionHandler
    func onFailure(messageID: String, error: KeyboardResponseError) {
        DispatchQueue.main.async {
            var message = "Send keyboard request unknown error".localized
            switch error {
            case .unknown:
                message = "Send keyboard request unknown error".localized
            case .noChat:
                message = "Chat does not exist".localized
            case .buttonIdNotSet:
                message = "Wrong button ID in request".localized
            case .requestMessageIdNotSet:
                message = "Wrong message ID in request".localized
            case .canNotCreateResponse:
                message = "Response cannot be created for this request".localized
            }
            
            let title = "Send keyboard request failed".localized
            
            self.alertDialogHandler.showSendFailureDialog(
                withMessage: message,
                title: title,
                action: { [weak self] in
                    guard self != nil else { return }
                
                // TODO: Make sure to delete message if needed
                }
            )
        }
    }
    
    func alertOnFailure(with message: String, id messageID: String, title: String) {
        alertDialogHandler.showSendFailureDialog(
            withMessage: message,
            title: title,
            action: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    for (index, message) in self.chatMessages.enumerated() {
                        if message.getID() == messageID {
                            self.chatMessages.remove(at: index)
                            self.chatTableView?.reloadData()
                            return
                        }
                    }
                }
            }
        )
    }
}

extension ChatViewController: FatalErrorHandlerDelegate {
    
    // MARK: - Methods
    func showErrorDialog(withMessage message: String) {
        let alertController = UIAlertController(
            title: "Session creation failed".localized,
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(
            title: "Ok".localized,
            style: .cancel,
            handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true)
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            if let startViewController = navigationController.viewControllers.first as? WMStartViewController {
                navigationController.popViewController(animated: false)
                startViewController.startChatButton.isHidden = true
                startViewController.showErrorDialog(withMessage: message)
            }
        }
    }
    
}

extension ChatViewController: NotFatalErrorHandler {
    
    func on(error: RoxchatNotFatalError) {
    }
    
    func connectionStateChanged(connected: Bool) {
        self.setConnectionStatus(connected: connected)
    }
}
