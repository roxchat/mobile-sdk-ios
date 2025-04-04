
import Foundation

/**
 Class that encapsulates chat update data, received from a server.
 */
final class DeltaItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    enum DeltaType: String {
        case chat = "CHAT"
        case chatMessage = "CHAT_MESSAGE"
        case chatOperator = "CHAT_OPERATOR"
        case chatOperatorTyping = "CHAT_OPERATOR_TYPING"
        case chatReadByVisitor = "CHAT_READ_BY_VISITOR"
        case chatState = "CHAT_STATE"
        case chatUnreadByOperatorTimestamp = "CHAT_UNREAD_BY_OPERATOR_SINCE_TS"
        case departmentList = "DEPARTMENT_LIST"
        case historyRevision = "HISTORY_REVISION"
        case offlineChatMessage = "OFFLINE_CHAT_MESSAGE"
        case operatorRate = "OPERATOR_RATE"
        case survey = "SURVEY"
        case unreadByVisitor = "UNREAD_BY_VISITOR"
        case visitSession = "VISIT_SESSION"
        case visitSessionState = "VISIT_SESSION_STATE"
        case chatMessageRead = "MESSAGE_READ"
        case chatId = "CHAT_ID"
    }
    enum Event: String {
        case add = "add"
        case delete = "del"
        case update = "upd"
    }
    enum UnreadByVisitorField: String {
        case timestamp = "sinceTs"
        case messageCount = "msgCnt"
    }
    private enum JSONField: String {
        case data = "data"
        case event = "event"
        case objectType = "objectType"
        case id = "id"
    }
    
    // MARK: - Properties
    private var data: Any?
    private var event: Event
    private var deltaType: DeltaType?
    private var id: String
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        guard let eventString = jsonDictionary[JSONField.event.rawValue] as? String,
            let event = Event(rawValue: eventString) else {
            return nil
        }
        self.event = event
        
        guard let id = jsonDictionary[JSONField.id.rawValue] as? String else {
            return nil
        }
        self.id = id
        
        self.data = jsonDictionary[JSONField.data.rawValue] ?? nil
        
        if let objectTypeString = jsonDictionary[JSONField.objectType.rawValue] as? String {
            deltaType = DeltaType(rawValue: objectTypeString)
        }
    }
    
    // MARK: - Methods
    
    func getDeltaType() -> DeltaType? {
        return deltaType
    }
    
    func getID() -> String {
        return id
    }
    
    func getEvent() -> Event {
        return event
    }
    
    func getData() -> Any? {
        return data
    }
    
}
