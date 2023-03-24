
import Foundation

/**
 */
protocol HistoryStorage {
    
    /**
     When this values is changed history will be re-requested.
     */
    func getMajorVersion() -> Int
    
    func set(reachedHistoryEnd: Bool)
    
    func getFullHistory(completion: @escaping ([Message]) -> ())
    
    func getLatestHistory(byLimit limitOfMessages: Int,
                          completion: @escaping ([Message]) -> ())
    
    func getHistoryBefore(id: HistoryID,
                          limitOfMessages: Int,
                          completion: @escaping ([Message]) -> ())
    func clearHistory()
    
    func receiveHistoryBefore(messages: [MessageImpl],
                              hasMoreMessages: Bool)
    
    func receiveHistoryUpdate(withMessages messages: [MessageImpl],
                              idsToDelete: Set<String>,
                              completion: @escaping (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) -> ())
    
    func updateReadBeforeTimestamp(timestamp: Int64)
}
