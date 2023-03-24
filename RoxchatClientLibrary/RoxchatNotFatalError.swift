
import Foundation

/**
 Abstracts Roxchat service possible error responses.
 - seealso:
 `FatalErrorHandler` protocol.
 */
public protocol RoxchatNotFatalError {
    
    /**
     - returns:
     Parsed type of the error.
     */
    func getErrorType() -> NotFatalErrorType
    
    /**
     - returns:
     String representation of an error.
     */
    func getErrorString() -> String
    
}

/**
 Roxchat service error types.
 - important:
 Mind that most of this errors causes session to destroy.
 */
public enum NotFatalErrorType {
    
    /**
     This error indicates no network connection.
     */
    case noNetworkConnection
    
    @available(*, unavailable, renamed: "noNetworkConnection")
    case NO_NETWORK_CONNECTION
    
    /**
     This error occurs when server is not available.
     */
    case serverIsNotAvailable
    
    @available(*, unavailable, renamed: "serverIsNotAvailable")
    case SERVER_IS_NOT_AVAILABLE
    
}
