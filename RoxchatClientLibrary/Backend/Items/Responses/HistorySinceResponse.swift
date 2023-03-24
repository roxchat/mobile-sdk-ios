
import Foundation

/**
 */
struct HistorySinceResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    enum JSONField: String {
        case data = "data"
    }
    
    // MARK: - Properties
    private var historyResponseData: HistoryResponseData?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let dataDictionary = jsonDictionary[JSONField.data.rawValue] as? [String: Any?] {
            historyResponseData = HistoryResponseData(jsonDictionary: dataDictionary)
        }
    }
    
    // MARK: - Methods
    func getData() -> HistoryResponseData? {
        return historyResponseData
    }
    
    // MARK: -
    struct HistoryResponseData {
        
        // MARK: - Constants
        // Raw values equal to field names received in responses from server.
        enum JSONField: String {
            case hasMore = "hasMore"
            case messages = "messages"
            case revision = "revision"
        }
        
        // MARK: - Properties
        private var hasMore: Bool?
        private var messages: [MessageItem]?
        private var revision: String?
        
        // MARK: - Initialization
        init(jsonDictionary: [String: Any?]) {
            var messages = [MessageItem]()
            if let messagesArray = jsonDictionary[JSONField.messages.rawValue] as? [Any?] {
                for item in messagesArray {
                    if let messageDictionary = item as? [String: Any?] {
                        let messageItem = MessageItem(jsonDictionary: messageDictionary)
                        messages.append(messageItem)
                    }
                }
            }
            self.messages = messages
            
            hasMore = ((jsonDictionary[JSONField.hasMore.rawValue] as? Bool) ?? false)
            revision = jsonDictionary[JSONField.revision.rawValue] as? String
        }
        
        // MARK: - Methods
        
        func getMessages() -> [MessageItem]? {
            return messages
        }
        
        func isHasMore() -> Bool? {
            return hasMore
        }
        
        func getRevision() -> String? {
            return revision
        }
        
    }
    
}
