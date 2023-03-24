
import Foundation

/**
 Abstracts a remote notifications from Roxchat service.
 - seealso:
 `Roxchat.parseRemoteNotification()`
 */
public protocol RoxchatRemoteNotification {
    
    /**
     - seealso:
     `NotificationType` enum.
     - returns:
     Type of this remote notification.
     */
    func getType() -> NotificationType?
    
    /**
     - seealso:
     `NotificationEvent` enum.
     - returns:
     Event of this remote notification.
     */
    func getEvent() -> NotificationEvent?
    
    /**
     - returns:
     Parameters of this remote notification. Each `NotificationType` has specific list of parameters.
     - seealso:
     `NotificationType`
     */
    func getParameters() -> [String]
    
    /**
     - returns:
     Chat location.
     - seealso:
     `NotificationType`
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func getLocation() -> String?
    
    /**
     - returns:
     Unread by visitor messages count.
     - seealso:
     `NotificationType`
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func getUnreadByVisitorMessagesCount() -> Int

}

/**
 - seealso:
 `RoxchatRemoteNotification.getType()`
 `RoxchatRemoteNotification.getParameters()`
 */
public enum NotificationType {
    
    /**
     This notification type indicated that contact information request is sent to a visitor.
     Parameters: empty.
     */
    case contactInformationRequest
    
    @available(*, unavailable, renamed: "contactInformationRequest")
    case CONTACT_INFORMATION_REQUEST
    
    /**
     This notification type indicated that an operator has connected to a dialogue.
     Parameters:
     * Operator's name.
     */
    case operatorAccepted
    
    @available(*, unavailable, renamed: "operatorAccepted")
    case OPERATOR_ACCEPTED
    
    /**
     This notification type indicated that an operator has sent a file.
     Parameters:
     * Operator's name;
     * File name.
     */
    case operatorFile
    
    @available(*, unavailable, renamed: "operatorFile")
    case OPERATOR_FILE
    
    /**
     This notification type indicated that an operator has sent a text message.
     Parameters:
     * Operator's name;
     * Message text.
     */
    case operatorMessage
    
    @available(*, unavailable, renamed: "operatorMessage")
    case OPERATOR_MESSAGE
    
    /**
     This notification type indicated that an operator has sent a widget message.
     Parameters: empty.
     - important:
     This type can be received only if server supports this functionality.
     */
    case widget
    
    @available(*, unavailable, renamed: "widget")
    case WIDGET
    
    /**
     This notification type indicated that an operator has sent rate operator widget.
     Parameters: empty.
     - important:
     This type can be received only if server supports this functionality.
     */
    case rateOperator
}

/**
 - seealso:
 `RoxchatRemoteNotification.getEvent()`
 */
public enum NotificationEvent {
    
    /**
     Means that a notification should be added by current remote notification.
     */
    case add
    
    @available(*, unavailable, renamed: "add")
    case ADD
    
    /**
     Means that a notification should be deleted by current remote notification.
     */
    case delete
    
    @available(*, unavailable, renamed: "delete")
    case DELETE
    
}
