
import Foundation

/**
 Class that is responsible for tracking changes of message stream.
 */
final class MessageTrackerImpl {
    
    // MARK: - Properties
    private let messageHolder: MessageHolder
    var idToHistoryMessageMap = [String: MessageImpl]()
    weak var messageListener: MessageListener?
    private var allMessageSourcesEnded = false
    private var cachedCompletionHandler: MessageHolderCompletionHandlerWrapper?
    private var cachedLimit: Int?
    private var destroyed: Bool?
    private var headMessage: MessageImpl?
    private var firstHistoryUpdateReceived: Bool?
    private var messagesLoading: Bool?
    private var currentChatMessagesWereReceived = false
    
    // MARK: - Initialization
    init(messageListener: MessageListener,
         messageHolder: MessageHolder) {
        self.messageListener = messageListener
        self.messageHolder = messageHolder
    }
    
    // MARK: - Methods
    
    func addedNew(message: MessageImpl,
                  of messageHolder: MessageHolder) {
        do {
            try message.getSource().assertIsCurrentChat()
        } catch {
            RoxchatInternalLogger.shared.log(entry: "Message which is being added is not a part of current chat: \(message.toString()).",
                verbosityLevel: .debug)
            
            return
        }
        
        addNewOrMerge(message: message,
                      of: messageHolder)
        
        if (headMessage == nil)
            || allMessageSourcesEnded {
            // FIXME: Do it on endOfBatch only.
            if let completionHandler = cachedCompletionHandler {
                getNextUncheckedMessagesBy(limit: (cachedLimit ?? 0),
                                           completion: completionHandler.getCompletionHandler())
                
                cachedCompletionHandler = nil
            }
        }
    }
    
    func addedNew(messages: [MessageImpl],
                  of messageHolder: MessageHolder) {
        if !messages.isEmpty {
            if (headMessage != nil)
                || allMessageSourcesEnded {
                for message in messages {
                    addNewOrMerge(message: message,
                                  of: messageHolder)
                }
            } else {
                var currentChatMessages = messageHolder.getCurrentChatMessages()
                currentChatMessages.append(contentsOf: messages)
                messageHolder.set(currentChatMessages: currentChatMessages)
                
                if let completionHandler = cachedCompletionHandler {
                    getNextUncheckedMessagesBy(limit: (cachedLimit ?? 0),
                                               completion: completionHandler.getCompletionHandler())
                
                    cachedCompletionHandler = nil
                }
            }
        }
    }
    
    func changedCurrentChatMessage(from previousVersion: MessageImpl,
                                   to newVersion: MessageImpl,
                                   at index: Int,
                                   of messageHolder: MessageHolder) {
        do {
            try previousVersion.getSource().assertIsCurrentChat()
        } catch {
            RoxchatInternalLogger.shared.log(entry: "Message which is being changed is not a part of current chat: \(previousVersion.toString()).",
                verbosityLevel: .debug)
            
            return
        }
        do {
            try newVersion.getSource().assertIsCurrentChat()
        } catch {
            RoxchatInternalLogger.shared.log(entry: "Replacement message for a current chat message is not a part of current chat: \(newVersion.toString()).",
                verbosityLevel: .debug)
            
            return
        }
        
        guard let headMessage = headMessage else {
            return
        }
        
        if headMessage.getSource().isHistoryMessage() {
            if previousVersion == headMessage {
                self.headMessage = newVersion
            }
            
            messageListener?.changed(message: previousVersion,
                                     to: newVersion)
        } else {
            let currentChatMessages = messageHolder.getCurrentChatMessages()
            for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                if currentChatMessage.getID() == headMessage.getID() {
                    if index >= currentChatMessageIndex {
                        if previousVersion == headMessage {
                            self.headMessage = newVersion
                        }
                        
                        messageListener?.changed(message: previousVersion,
                                                 to: newVersion)
                    }
                    
                    return
                }
            }
        }
    }
    
    func deletedCurrentChat(message: MessageImpl,
                            at index: Int,
                            messageHolder: MessageHolder) {
        do {
            try message.getSource().assertIsCurrentChat()
        } catch {
            RoxchatInternalLogger.shared.log(entry: "Message which is being deleted is not a part of current chat: \(message.toString())",
                verbosityLevel: .debug)
        }
        
        let currentChatMessages = messageHolder.getCurrentChatMessages()
        
        guard let headMessage = headMessage else {
            return
        }
        
        let headIndex = currentChatMessages.firstIndex(of: headMessage) ?? -1
        
        if headMessage.getSource().isHistoryMessage()
            || (index > headIndex) {
            if headIndex == (index + 1) {
                self.headMessage = (currentChatMessages.count < headIndex) ? nil : currentChatMessages[headIndex]
            }
            
            messageListener?.removed(message: message)
        }
    }
    
    func endedHistoryBatch() {
        guard firstHistoryUpdateReceived != true else {
            return
        }
        
        firstHistoryUpdateReceived = true
        
        if let completionHandler = cachedCompletionHandler {
            getNextUncheckedMessagesBy(limit: (cachedLimit ?? 0),
                                       completion: completionHandler.getCompletionHandler())
            
            cachedCompletionHandler = nil
        }
    }
    
    func deletedHistoryMessage(withID messageID: String) {
        guard let message = idToHistoryMessageMap[messageID] else {
            return
        }
        idToHistoryMessageMap[messageID] = nil
        
        guard let headMessage = headMessage else {
            return
        }
        if headMessage.getSource().isHistoryMessage()
            && (message.getTimeInMicrosecond() >= headMessage.getTimeInMicrosecond()) {
            messageListener?.removed(message: message)
        }
    }
    
    func changedHistory(message: MessageImpl) {
        do {
            try message.getSource().assertIsHistory()
        } catch {
            RoxchatInternalLogger.shared.log(
                entry: "Message which is being changed is not a part of history: \(message.toString()).",
                verbosityLevel: .debug,
                logType: .messageHistory)
        }
        
        guard let headMessage = headMessage,
            let messageHistoryID = message.getHistoryID(),
            headMessage.getSource().isHistoryMessage(),
            message.getTimeInMicrosecond() >= headMessage.getTimeInMicrosecond() else {
                return
        }
        
        let previousMessage: MessageImpl? = idToHistoryMessageMap[messageHistoryID.getDBid()]
        if let previousMessage = previousMessage {
            idToHistoryMessageMap[messageHistoryID.getDBid()] = message
            messageListener?.changed(message: previousMessage,
                                     to: message)
        } else {
            RoxchatInternalLogger.shared.log(
                entry: "Unknown message was changed: \(message.toString())",
                verbosityLevel: .debug,
                logType: .messageHistory)
        }
    }
    
    func addedHistory(message: MessageImpl,
                      before id: HistoryID?) {
        do {
            try message.getSource().assertIsHistory()
        } catch {
            RoxchatInternalLogger.shared.log(
                entry: "Message which is being added is not a part of history: \(message.toString()).",
                verbosityLevel: .debug,
                logType: .messageHistory)
            
            return
        }
        
         guard let headMessage = headMessage,
            let messageHistoryID = message.getHistoryID(),
            headMessage.getSource().isHistoryMessage() else {
                return
        }
        
        if let beforeID = id {
            if let beforeMessage = idToHistoryMessageMap[beforeID.getDBid()] {
                messageListener?.added(message: message,
                                       after: beforeMessage)
            }
        } else {
            let currentChatMessages = messageHolder.getCurrentChatMessages()
            messageListener?.added(message: message,
                                   after: (currentChatMessages.isEmpty ? nil : currentChatMessages.last))
        }
        
        idToHistoryMessageMap[messageHistoryID.getDBid()] = message
    }
    
    // For testing purposes.
    func set(messagesLoading: Bool) {
        self.messagesLoading = messagesLoading
    }
    
    // MARK: Private methods
    
    private func addNewOrMerge(message: MessageImpl,
                               of messageHolder: MessageHolder) {
        do {
            try message.getSource().assertIsCurrentChat()
        } catch {
            RoxchatInternalLogger.shared.log(entry: "Message which is being added is not a part of current chat: \(message.toString()).",
                verbosityLevel: .debug)
            
            return
        }
        
        var toCallMessageAdded = true
        
        var currentChatMessages = messageHolder.getCurrentChatMessages()
        
        if let headMessage = headMessage {
            if (headMessage.getTimeInMicrosecond()) > message.getTimeInMicrosecond() {
                toCallMessageAdded = false
                
                currentChatMessages.append(message)
            } else {
                for (historyID, historyMessage) in idToHistoryMessageMap {
                    if message.getID() == historyMessage.getID() {
                        toCallMessageAdded = false
                        
                        let replacingMessage = historyMessage.transferToCurrentChat(message: message)
                        currentChatMessages.append(replacingMessage)
                        if (replacingMessage != historyMessage) {
                            messageListener?.changed(message: historyMessage,
                                                     to: replacingMessage)
                        }
                        
                        idToHistoryMessageMap[historyID] = nil
                        
                        break
                    }
                }
            }
        } else {
            self.headMessage = message
        }
        
        if toCallMessageAdded {
            for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                if currentChatMessage.getID() == message.getID() {
                    currentChatMessages[currentChatMessageIndex] = message
                    messageListener?.changed(message: currentChatMessage,
                                             to: message)
                    messageHolder.set(currentChatMessages: currentChatMessages)
                    
                    break
                }
            }
            
            currentChatMessages.append(message)
            
            if let messageToSend = getToSendMirrorAndRemove(message: message,
                                                            of: messageHolder) {
                messageListener?.changed(message: messageToSend,
                                         to: message)
            } else {
                let messagesToSend = messageHolder.getMessagesToSend()
                if !messagesToSend.isEmpty,
                    let firstMessage = messagesToSend.first {
                    messageListener?.added(message: message,
                                            after: firstMessage)
                } else {
                    messageListener?.added(message: message, after: nil)
                }
            }
        }
        
        messageHolder.set(currentChatMessages: currentChatMessages)
    }
    
    private func getToSendMirrorAndRemove(message: MessageImpl,
                                          of messageHolder: MessageHolder) -> MessageToSend? {
        let messagesToSend = messageHolder.getMessagesToSend()
        
        for i in 0..<messagesToSend.count {
            if messagesToSend[i].getID() == message.getID() {
                let messageToSend = messagesToSend[i]
                messageHolder.removeFromMessagesToSendAt(index: i)
                return messageToSend
            }
        }
        
        return nil
    }
    
    private func getNextUncheckedMessagesBy(limit: Int,
                                            completion: @escaping ([Message]) -> ()) {
        let completionHandler = { [weak self] (messages: [Message]) -> () in
            guard let messages = messages as? [MessageImpl] else {
                RoxchatInternalLogger.shared.log(entry: "Wrong messages type in MessageTrackerImpl.\(#function)")
                return
            }
            self?.receive(messages: messages,
                          limit: limit,
                          completion: completion)
            
            self?.messagesLoading = false
        }
        
        if let headMessage = headMessage {
            messageHolder.getMessagesBy(limit: limit,
                                        before: headMessage,
                                        completion: completionHandler)
        } else {
            messageHolder.getLatestMessages(byLimit: limit,
                                            completion: completionHandler)
        }
    }
    
    private func receive(messages: [MessageImpl],
                         limit: Int,
                         completion: @escaping ([Message]) -> ()) {
        var result: [MessageImpl]?
        
        if !messages.isEmpty {
            let currentChatMessages = messageHolder.getCurrentChatMessages()
            if !currentChatMessages.isEmpty {
                if let first = currentChatMessages.first,
                    let last = messages.last,
                    let firstMessage = messages.first,
                    last.getTime() >= first.getTime() {
                    // We received history that overlap current chat messages. Merging.
                    
                    var filteredMessages = [MessageImpl]()
                    
                    for message in messages {
                        var addToFilteredMessages = true
                        
                        if message.getSource().isHistoryMessage() {
                            let messageTime = message.getTime()
                            if (messageTime >= first.getTime())
                                && (messageTime <= last.getTime())
                                && messageHolder.getCurrentChatMessagesWereReceived() {
                                for currentChatMessage in currentChatMessages {
                                    if currentChatMessage.getID() == message.getID() {
                                        
                                        addToFilteredMessages = false
                                        currentChatMessage.setSecondaryHistory(historyEquivalentMessage: message)
                                        break
                                    }
                                }
                            }
                        }
                        
                        if addToFilteredMessages {
                            filteredMessages.append(message)
                        }
                    }
                    
                    if filteredMessages.isEmpty {
                        let completionHandler = { [weak self] (messages: [Message]) -> () in
                            guard let messages = messages as? [MessageImpl] else {
                                RoxchatInternalLogger.shared.log(entry: "Wrong messages type in MessageTrackerImpl.\(#function)")
                                return
                            }
                            self?.receive(messages: messages,
                                          limit: limit,
                                          completion: completion)
                            
                            self?.messagesLoading = false
                        }
                        messageHolder.getMessagesBy(limit: limit,
                                                    before: firstMessage,
                                                    completion: completionHandler)
                        
                        return
                    }
                    
                    result = filteredMessages
                } else {
                    result = messages
                }
            } else {
                result = messages
            }
            
            for message in messages {
                guard let messageHistoryID = message.getHistoryID() else {
                    continue
                }
                if message.getSource().isHistoryMessage() {
                    idToHistoryMessageMap[messageHistoryID.getDBid()] = message
                }
            }
            
            guard let result = result,
                let firstMessage = result.first else {
                    RoxchatInternalLogger.shared.log(entry: "First message is nil in MessageTrackerImpl.\(#function)")
                    return
            }
            
            if let headMessage = headMessage {
                if firstMessage.getTimeInMicrosecond() < headMessage.getTimeInMicrosecond() {
                    self.headMessage = firstMessage
                }
            } else {
                self.headMessage = firstMessage
            }
        } else { // End `if !messages.isEmpty`
            result = messages
            
            allMessageSourcesEnded = true
        }
        
        
        guard let completionResult = result else {
                RoxchatInternalLogger.shared.log(entry: "Result is nil in MessageTrackerImpl.\(#function)")
                return
        }
        completion(completionResult)
    }
    
}

extension MessageTrackerImpl: MessageTracker {
    
    func getLastMessages(byLimit limitOfMessages: Int,
                         completion: @escaping ([Message]) -> ()) throws {
        try messageHolder.checkAccess()
        guard destroyed != true else {
            RoxchatInternalLogger.shared.log(entry: "MessageTracker object is destroyed. Unable to perform request to get new messages.")
            completion([Message]())
            
            return
        }
        guard messagesLoading != true else {
            RoxchatInternalLogger.shared.log(entry: "Messages are already loading. Unable to perform a second request to get new messages.")
            completion([Message]())
            
            return
        }
        guard limitOfMessages > 0 else {
            RoxchatInternalLogger.shared.log(entry: "Limit of messages to perform request to get new messages must be greater that zero. Passed value – \(limitOfMessages).")
            completion([Message]())
            
            return
        }
        
        let wrappedCompletion: ([Message]) -> () = { [weak self] messages in
            (self?.destroyed != false) ? completion(messages) : completion([Message]())
        }
        
        allMessageSourcesEnded = false
        messageHolder.set(reachedEndOfLocalHistory: false)
        messageHolder.set(currentChatMessagesWereReceived: false)
        let currentChatMessages = messageHolder.getCurrentChatMessages()
        if currentChatMessages.isEmpty {
            messagesLoading = true
            
            cachedCompletionHandler = MessageHolderCompletionHandlerWrapper(completionHandler: wrappedCompletion)
            cachedLimit = limitOfMessages
            
            messageHolder.getHistoryStorage().getLatestHistory(byLimit: limitOfMessages) { [weak self] messages in
                if let cachedCompletionHandler = self?.cachedCompletionHandler,
                   !messages.isEmpty || self?.messageHolder.getReachedEndOfRemoteHistory() == true {
                    self?.firstHistoryUpdateReceived = true
                    
                    let completionHandlerToPass = cachedCompletionHandler.getCompletionHandler()
                    guard let messages = messages as? [MessageImpl] else {
                        RoxchatInternalLogger.shared.log(entry: "Wrong messages type in MessageTrackerImpl.\(#function)")
                        return
                    }
                    self?.receive(messages: messages,
                                  limit: limitOfMessages,
                                  completion: completionHandlerToPass)
                    
                    self?.cachedCompletionHandler = nil
                    
                    self?.messagesLoading = false
                }
            }
        } else {
            messagesLoading = true
            let result = Array(currentChatMessages.suffix(limitOfMessages))
            headMessage = result.first
            
            wrappedCompletion(result)
            firstHistoryUpdateReceived = true
            messagesLoading = false
        }
    }
    
    func getNextMessages(byLimit limitOfMessages: Int,
                         completion: @escaping ([Message]) -> ()) throws {
        try messageHolder.checkAccess()
        guard destroyed != true else {
            RoxchatInternalLogger.shared.log(entry: "MessageTracker object is destroyed. Unable to perform request to get new messages.")
            completion([Message]())
            
            return
        }
        guard messagesLoading != true else {
            RoxchatInternalLogger.shared.log(entry: "Messages are already loading. Unable to perform a second request to get new messages.")
            completion([Message]())
            
            return
        }
        guard limitOfMessages > 0 else {
            RoxchatInternalLogger.shared.log(entry: "Limit of messages to perform request to get new messages must be greater that zero. Passed value – \(limitOfMessages).")
            completion([Message]())
            
            return
        }
        
        let wrappedCompletion: ([Message]) -> () = { [weak self] messages in
            (self?.destroyed != false) ? completion(messages) : completion([Message]())
        }
        
        messagesLoading = true
        let currentChatMessages = messageHolder.getCurrentChatMessages()
        if (firstHistoryUpdateReceived == true)
            || (!currentChatMessages.isEmpty
                && (currentChatMessages.first != headMessage)) {
            getNextUncheckedMessagesBy(limit: limitOfMessages,
                                       completion: wrappedCompletion)
        } else {
            cachedCompletionHandler = MessageHolderCompletionHandlerWrapper(completionHandler: wrappedCompletion)
            cachedLimit = limitOfMessages
            
            messageHolder.getHistoryStorage().getLatestHistory(byLimit: limitOfMessages) { [weak self] messages in
                if let cachedCompletionHandler = self?.cachedCompletionHandler,
                   !messages.isEmpty || self?.messageHolder.getReachedEndOfRemoteHistory() == true {
                    self?.firstHistoryUpdateReceived = true
                    
                    let completionHandlerToPass = cachedCompletionHandler.getCompletionHandler()
                    guard let messages = messages as? [MessageImpl] else {
                        RoxchatInternalLogger.shared.log(entry: "Wrong messages type in MessageTrackerImpl.\(#function)")
                        return
                    }
                    self?.receive(messages: messages,
                                  limit: limitOfMessages,
                                  completion: completionHandlerToPass)
                    
                    self?.cachedCompletionHandler = nil
                    
                    self?.messagesLoading = false
                }
            }
        }
    }
    
    func getAllMessages(completion: @escaping ([Message]) -> ()) throws {
        try messageHolder.checkAccess()
        guard destroyed != true else {
            RoxchatInternalLogger.shared.log(entry: "MessageTracker object is destroyed. Unable to perform request to get new messages.")
            completion([Message]())
            
            return
        }
        
        let wrappedCompletion: ([Message]) -> () = { [weak self] messages in
            (self?.destroyed != false) ? completion(messages) : completion([Message]())
        }
        
        messageHolder.getHistoryStorage().getFullHistory(completion: wrappedCompletion)
    }
    
    func resetTo(message: Message) throws {
        try messageHolder.checkAccess()
        guard destroyed != true else {
            RoxchatInternalLogger.shared.log(entry: "MessageTracker object was destroyed. Unable to perform a request to reset to a message.")
            
            return
        }
        guard messagesLoading != true else {
            RoxchatInternalLogger.shared.log(entry: "Messages is loading. Unable to perform a simultaneous request to reset to a message.")
            
            return
        }
        
        guard let unwrappedMessage = message as? MessageImpl else {
            RoxchatInternalLogger.shared.log(entry: "Wrong message type in MessageTrackerImpl.\(#function)")
            return
        }
        if unwrappedMessage != headMessage {
            messageHolder.set(reachedEndOfLocalHistory: false)
        }
        if unwrappedMessage.getSource().isHistoryMessage() {
            var newIDToHistoryMessageMap = [String: MessageImpl]()
            for (id, iteratedMessage) in idToHistoryMessageMap {
                if iteratedMessage.getTimeInMicrosecond() >= unwrappedMessage.getTimeInMicrosecond() {
                    newIDToHistoryMessageMap[id] = iteratedMessage
                }
            }
            idToHistoryMessageMap = newIDToHistoryMessageMap
        } else {
            idToHistoryMessageMap.removeAll()
        }
        
        headMessage = unwrappedMessage
    }
    
    func destroy() throws {
        try messageHolder.checkAccess()
        
        if destroyed != true {
            destroyed = true
            
            messageHolder.set(messagesToSend: [MessageToSend]())
            
            messageHolder.set(messageTracker: nil)
        }
    }
    
}
