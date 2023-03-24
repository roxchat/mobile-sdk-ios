
import Foundation

/**
 Class that is responsible for history storage when it is set to memory mode.
 */
final class MemoryHistoryStorage: HistoryStorage {
    
    // MARK: - Properties
    private let majorVersion = Int(InternalUtils.getCurrentTimeInMicrosecond() % Int64(Int.max))
    private lazy var historyMessages = [MessageImpl]()
    private var reachedHistoryEnd = false
    private var readBeforeTimestamp: Int64
    
    // MARK: - Initialization
    
    init() {
        // Empty initializer introduced because of init(with:) existence.
        self.readBeforeTimestamp = -1
    }
    
    init(readBeforeTimestamp: Int64) {
        self.readBeforeTimestamp = readBeforeTimestamp
    }
    
    // For testing purposes only.
    init(messagesToAdd: [MessageImpl]) {
        self.readBeforeTimestamp = -1
        for message in messagesToAdd {
            historyMessages.append(message)
        }
    }
    
    // MARK: - Methods
    // MARK: HistoryStorage protocol methods
    
    func getMajorVersion() -> Int {
        return majorVersion
    }
    
    func set(reachedHistoryEnd: Bool) {
        // No need in this implementation.
    }
    
    func getFullHistory(completion: @escaping ([Message]) -> ()) {
        completion(historyMessages as [Message])
    }
    
    func getLatestHistory(byLimit limitOfMessages: Int,
                          completion: @escaping ([Message]) -> ()) {
        respondTo(messages: historyMessages,
                  limitOfMessages: limitOfMessages,
                  completion: completion)
    }
    
    func getHistoryBefore(id: HistoryID,
                          limitOfMessages: Int,
                          completion: @escaping ([Message]) -> ()) {
        let sortedMessages = historyMessages.sorted {
            if let first = $0.getHistoryID() {
                if let second = $1.getHistoryID() {
                    return first.getTimeInMicrosecond() < second.getTimeInMicrosecond()
                }
                return true
            }
            return false
        }
        
        guard let firstHistoryID = sortedMessages[0].getHistoryID() else {
            completion([])
            return
        }
        
        guard firstHistoryID.getTimeInMicrosecond() <= id.getTimeInMicrosecond() else {
            completion([MessageImpl]())
            return
        }
        
        for (index, message) in sortedMessages.enumerated() {
            if message.getHistoryID() == id {
                respondTo(messages: sortedMessages,
                          limitOfMessages: limitOfMessages,
                          offset: index,
                          completion: completion)
                
                break
            }
        }
    }
    
    func receiveHistoryBefore(messages: [MessageImpl],
                              hasMoreMessages: Bool) {
        if !hasMoreMessages {
            reachedHistoryEnd = true
        }
        
        historyMessages = messages + historyMessages
    }
    
    func receiveHistoryUpdate(withMessages messages: [MessageImpl],
                              idsToDelete: Set<String>,
                              completion: @escaping (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) -> ()) {
        deleteFromHistory(idsToDelete: idsToDelete,
                          completion: completion)
        mergeHistoryChanges(messages: messages,
                            completion: completion)
        
        completion(true, false, nil, false, nil, false, nil, nil)
    }
    
    func clearHistory() {
        historyMessages.removeAll()
    }
    
    func updateReadBeforeTimestamp(timestamp: Int64) {
        self.readBeforeTimestamp = timestamp
    }
    
    // MARK: Private methods
    
    private func respondTo(messages: [MessageImpl],
                           limitOfMessages: Int,
                           completion: ([Message]) -> ()) {
        completion((messages.count == 0) ? messages : ((messages.count <= limitOfMessages) ? messages : Array(messages[(messages.count - limitOfMessages) ..< messages.count])))
    }
    
    private func respondTo(messages: [MessageImpl],
                           limitOfMessages: Int,
                           offset: Int,
                           completion: ([Message]) -> ()) {
        let supposedQuantity = offset - limitOfMessages
        completion(Array(messages[((supposedQuantity > 0) ? supposedQuantity : 0) ..< offset]))
    }
    
    private func deleteFromHistory(idsToDelete: Set<String>,
                                   completion: (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) -> ()) {
        for idToDelete in idsToDelete {
            for (index, message) in historyMessages.enumerated() {
                if message.getHistoryID()?.getDBid() == idToDelete {
                    historyMessages.remove(at: index)
                    completion(false, true, message.getHistoryID()?.getDBid(), false, nil, false, nil, nil)
                    
                    break
                }
            }
        }
    }
    
    private func mergeHistoryChanges(messages: [MessageImpl],
                                     completion: (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) -> ()) {
        /*
         Algorithm merges messages with history messages.
         Messages before first history message are ignored.
         Messages with the same time in Microseconds with corresponding history messages are replacing them.
         Messages after last history message are added in the end.
         The rest of the messages are merged in the middle of history messages.
         */
        
        var receivedMessages = messages
        var result = [MessageImpl]()
        
        outerLoop: for historyMessage in historyMessages {
            while receivedMessages.count > 0 {
                for message in receivedMessages {
                    if (message.getTimeInMicrosecond() <= readBeforeTimestamp || readBeforeTimestamp == -1) {
                        message.setRead(isRead: true)
                    }
                    if message.getTimeInMicrosecond() < historyMessage.getTimeInMicrosecond() {
                        if !result.isEmpty {
                            result.append(message)
                            completion(false, false, nil, false, nil, true, message, historyMessage.getHistoryID())
                            
                            receivedMessages.remove(at: 0)
                            
                            continue
                        } else {
                            receivedMessages.remove(at: 0)
                            
                            break
                        }
                    }
                    
                    if message.getTimeInMicrosecond() > historyMessage.getTimeInMicrosecond() {
                        result.append(historyMessage)
                        
                        continue outerLoop
                    }
                    
                    if message.getTimeInMicrosecond() == historyMessage.getTimeInMicrosecond() {
                        result.append(message)
                        completion(false, false, nil, true, message, false, nil, nil)
                        
                        receivedMessages.remove(at: 0)
                        
                        continue outerLoop
                    }
                }
            }
            
            result.append(historyMessage)
        }
        
        if receivedMessages.count > 0 {
            for message in receivedMessages {
                result.append(message)
                completion(false, false, nil, false, nil, true, message, nil)
            }
        }
        
        historyMessages = result
    }
        
}
