
import Foundation

/**
 */
final class RoxchatRemoteNotificationImpl {
    
    // MARK: - Constants
    enum APNSField: String {
        case aps = "aps"
        case roxchat = "roxchat"
        case unreadByVisitorMessagesCount = "unread_by_visitor_msg_cnt"
        case location = "location"
    }
    enum APSField: String {
        case alert = "alert"
    }
    private enum AlertField: String {
        case event = "event"
        case parameters = "loc-args"
        case type = "loc-key"
    }
    private enum InternalNotificationEvent: String {
        case add = "add"
        case delete = "del"
    }
    private enum InternalNotificationType: String {
        case contactInformationRequest = "P.CR"
        case operatorAccepted = "P.OA"
        case operatorFile = "P.OF"
        case operatorMessage = "P.OM"
        case widget = "P.WM"
        case rateOperator = "P.RO"
    }
    
    // MARK: - Properties
    private var event: InternalNotificationEvent? = nil
    private lazy var parameters = [String]()
    private var type: InternalNotificationType?
    private var location: String?
    private var unreadByVisitorMessagesCount = 0
    
    // MARK: - Initialization
    /*init?(jsonDictionary: [String: Any?]) {
        guard let typeString = jsonDictionary[AlertField.type.rawValue] as? String,
            let type = InternalNotificationType(rawValue: typeString) else {
            return nil
        }
        self.type = type
        
        if let eventString = jsonDictionary[AlertField.event.rawValue] as? String,
            let event = InternalNotificationEvent(rawValue: eventString) {
            self.event = event
        }
        
        if let parameters = jsonDictionary[AlertField.parameters.rawValue] as? [String] {
            self.parameters = parameters
        }
    }*/
    
    init?(jsonDictionary: [String: Any?]) {
        guard let apsFields = jsonDictionary[APNSField.aps.rawValue] as? [String: Any],
            let alertFields = apsFields[APSField.alert.rawValue] as? [String: Any] else {
                return nil
        }
        
        if let typeString = alertFields[AlertField.type.rawValue] as? String,
            let type = InternalNotificationType(rawValue: typeString) {
                self.type = type
        }
                
        if let eventString = alertFields[AlertField.event.rawValue] as? String,
            let event = InternalNotificationEvent(rawValue: eventString) {
                self.event = event
        }
        
        if let parameters = alertFields[AlertField.parameters.rawValue] as? [String] {
            self.parameters = parameters
        }
        
        if let location = jsonDictionary[APNSField.location.rawValue] as? String {
            self.location = location
        }
        
        if let unreadByVisitorMessagesCount = jsonDictionary[APNSField.unreadByVisitorMessagesCount.rawValue] as? Int {
            self.unreadByVisitorMessagesCount = unreadByVisitorMessagesCount
        }
        
    }
    
}

extension RoxchatRemoteNotificationImpl: RoxchatRemoteNotification {
    
    // MARK: - Methods
    // MARK: RoxchatRemoteNotification protocol methods
    
    func getType() -> NotificationType? {
        guard let type = self.type else {
            return nil
        }
        switch type {
        case .contactInformationRequest:
            return .contactInformationRequest
        case .operatorAccepted:
            return .operatorAccepted
        case .operatorFile:
            return .operatorFile
        case .operatorMessage:
            return .operatorMessage
        case .widget:
            return .widget
        case .rateOperator:
            return .rateOperator
        }
    }
    
    func getEvent() -> NotificationEvent? {
        if let event = event {
            switch event {
            case .add:
                return .add
            case .delete:
                return .delete
            }
        }
        return nil
    }
    
    func getParameters() -> [String] {
        return parameters
    }
    
    func getLocation() -> String? {
        return location
    }
    
    func getUnreadByVisitorMessagesCount() -> Int {
        return unreadByVisitorMessagesCount
    }
    
}
