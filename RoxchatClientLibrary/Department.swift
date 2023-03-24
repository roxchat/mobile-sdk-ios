
import Foundation

/**
 Single department entity. Provides methods to get department information.
 Department objects can be received through `DepartmentListChangeListener` protocol methods and `getDepartmentList()` method of `MessageStream` protocol.
 */
public protocol Department {
    
    /**
     Department key is used to start chat with some department.
     - seealso:
     `startChat(departmentKey:)` method of `MessageStream` protocol.
     - returns:
     Department key value that uniquely identifies this department.
     */
    func getKey() -> String
    
    /**
     - returns:
     Department public name.
     */
    func getName() -> String
    
    /**
     - seealso:
     `DepartmentOnlineStatus`.
     - returns:
     Department online status.
     */
    func getDepartmentOnlineStatus() -> DepartmentOnlineStatus
    
    /**
     - returns:
     Order number. Higher numbers match higher priority.
     */
    func getOrder() -> Int
    
    /**
     - returns:
     Dictionary of department localized names (if exists). Key is custom locale descriptor, value is matching name.
     */
    func getLocalizedNames() -> [String: String]?
    
    /**
     - returns:
     Department logo URL (if exists).
     */
    func getLogoURL() -> URL?
    
}

/**
 Possible department online statuses.
 - seealso:
 `getDepartmentOnlineStatus()` of `Department` protocol.
 */
public enum DepartmentOnlineStatus {
    
    /**
     Offline state with chats' count limit exceeded.
     */
    case busyOffline
    
    @available(*, unavailable, renamed: "busyOffline")
    case BUSY_OFFLINE
    
    /**
     Online state with chats' count limit exceeded.
     */
    case busyOnline
    
    @available(*, unavailable, renamed: "busyOnline")
    case BUSY_ONLINE
    
    /**
     Visitor is able to send offline messages.
     */
    case offline
    
    @available(*, unavailable, renamed: "offline")
    case OFFLINE
    
    /**
     Visitor is able to send both online and offline messages.
     */
    case online
    
    @available(*, unavailable, renamed: "online")
    case ONLINE
    
    /**
     Any status that is not supported by this version of the library.
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
}
