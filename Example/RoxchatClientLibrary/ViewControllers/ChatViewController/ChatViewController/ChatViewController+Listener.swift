
import Foundation
import RoxchatClientLibrary

extension ChatViewController: MessageListener {
    
    // MARK: - Methods
    
    func added(message newMessage: Message,
               after previousMessage: Message?) {
        DispatchQueue.main.async {
            var inserted = false
            
            if let previousMessage = previousMessage {
                for (index, message) in self.chatMessages.enumerated() {
                    if previousMessage.isEqual(to: message) {
                        self.chatMessages.insert(newMessage, at: index)
                        inserted = true
                        break
                    }
                }
            }
            
            if !inserted {
                self.chatMessages.append(newMessage)
            }
            
            self.chatTableView?.reloadData()

            if (!newMessage.isOperatorType() && !newMessage.isSystemType()) ||
                self.isLastCellVisible() {
                self.scrollToBottom(animated: true)
            }
            self.messageCounter.set(lastMessageIndex: self.chatMessages.count - 1)
        }
    }
    
    func removed(message: Message) {
        DispatchQueue.main.async {
            var toUpdate = false
            if message.getCurrentChatID() == self.selectedMessage?.getCurrentChatID() {
                self.toolbarView.removeQuoteEditBar()
            }
            
            for (messageIndex, iteratedMessage) in self.chatMessages.enumerated() {
                if iteratedMessage.getID() == message.getID() {
                    self.chatMessages.remove(at: messageIndex)
                    let indexPath = IndexPath(row: messageIndex, section: 0)
                    self.cellHeights.removeValue(forKey: indexPath)
                    toUpdate = true
                    
                    break
                }
            }
            
            if toUpdate {
                self.chatTableView?.reloadData()
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    func removedAllMessages() {
        DispatchQueue.main.async {
            self.chatMessages.removeAll()
            self.cellHeights.removeAll()
            self.chatTableView?.reloadData()
        }
    }
    
    func changed(message oldVersion: Message,
                 to newVersion: Message) {
        DispatchQueue.main.async {
            for (messageIndex, iteratedMessage) in self.chatMessages.enumerated() {
                if iteratedMessage.getID() == oldVersion.getID() {
                    self.chatMessages[messageIndex] = newVersion
                }
            }
            self.chatTableView.reloadData()
        }
    }
}

extension ChatViewController: HelloMessageListener {
    func helloMessage(message: String) {
        print("Received Hello message: \"\(message)\"")
    }
}

extension ChatViewController: OperatorTypingListener {
    func onOperatorTypingStateChanged(isTyping: Bool) {
        guard RoxchatServiceController.currentSession.getCurrentOperator() != nil else { return }
        guard isCurrentOperatorRated() == false else { return }

        if isTyping {
            self.updateOperatorStatus(typing: true, operatorStatus: "typing".localized)
        } else {
            self.updateOperatorStatus(typing: false, operatorStatus: "Online".localized)
        }
    }
}

extension ChatViewController: CurrentOperatorChangeListener {
    func changed(operator previousOperator: Operator?, to newOperator: Operator?) {
        updateCurrentOperatorInfo(to: newOperator)
    }
}

extension ChatViewController: ChatStateListener {
    func changed(state previousState: ChatState, to newState: ChatState) {
        if (newState == .closedByVisitor || newState == .closedByOperator ) && (RoxchatServiceController.currentSession.sessionState() == .chatting || RoxchatServiceController.currentSession.sessionState() == .queue) {
            self.showRateOperatorDialog(operatorId: currentOperatorId())
        }

        if newState == .invitation || newState == .chatting || newState == .queue {
            guard let currentId = currentOperatorId() else { return }
            alreadyRatedOperators[currentId] = false
            updateCurrentOperatorInfo(to: RoxchatServiceController.currentSession.getCurrentOperator())
        }
    }
}
