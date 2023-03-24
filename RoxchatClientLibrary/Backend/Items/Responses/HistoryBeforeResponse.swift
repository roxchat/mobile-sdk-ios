
import Foundation

/**
 */
struct HistoryBeforeResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    enum JSONField: String {
        case data = "data"
    }
    
    // MARK: - Properties
    private var historyResponseData: HistoryResponseData?
    private var result: String?
    
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
        }
        
        // MARK: - Properties
        private var hasMore: Bool
        private var messages: [MessageItem]?
        
        // MARK: - Initialization
        init(jsonDictionary: [String: Any?]) {
            messages = [MessageItem]()
            if let messagesArray = jsonDictionary[JSONField.messages.rawValue] as? [Any?] {
                for item in messagesArray {
                    if let messageDictionary = item as? [String: Any?] {
                        let messageItem = MessageItem(jsonDictionary: messageDictionary)
                        messages?.append(messageItem)
                    }
                }
            }
            
            hasMore = ((jsonDictionary[JSONField.hasMore.rawValue] as? Bool) ?? false)
        }
        
        // MARK: - Methods
        
        func isHasMore() -> Bool {
            return hasMore
        }
        
        func getMessages() -> [MessageItem]? {
            return messages
        }
        
    }
    
}
