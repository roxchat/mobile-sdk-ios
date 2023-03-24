
import Foundation

/**
 */
enum VisitSessionStateItem: String {
    // Raw values equal to field names received in responses from server.
    case callbackHunter = "callback-hunter"
    case chat = "chat"
    case chatShowing = "chat-showing"
    case departmentSelection = "department-selection"
    case end = "end"
    case firstQuestion = "first-question"
    case idle = "idle"
    case idleAfterChat = "idle-after-chat"
    case offlineMessage = "offline-message"
    case showing = "showing"
    case showingAuto = "showing-auto"
    case showingByURLParameter = "showing-by-url-param"
    case unknown
}
