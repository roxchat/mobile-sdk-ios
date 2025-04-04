
import Foundation

/**
 Protocol that provides methods for implementing custom RoxchatClientLibrary network requests logging.
 It can be useful for debugging production releases if debug logs are not available.
 */
public protocol RoxchatAlert: AnyObject {
    
    /**
     Method which is called after new RoxchatClientLibrary network request log entry came out.
     - parameter entry:
     New RoxchatClientLibrary network request log entry.
     */
    func present(title: RoxchatAlertTitle, message: RoxchatAlertMessage)
    
}

/**
 */
public enum RoxchatAlertTitle {
    /**
     Account access notice.
     */
    case accountError
    /**
     Network access notice.
     */
    case networkError
    /**
     Visitor action notice.
     */
    case visitorActionError
}

/**
 */
public enum RoxchatAlertMessage {
    /**
     Account is not reachable or active.
     */
    case accountConnectionError
    /**
     File deleting is failed.
     */
    case fileDeletingError
    /**
     File sending is failed.
     */
    case fileSendingError
    /**
     Operator rating is failed.
     */
    case operatorRatingError
    /**
     Network connection is disabled.
     */
    case noNetworkConnection
}
