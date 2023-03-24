
import Foundation

/**
 Abstracts Roxchat service possible error responses.
 - seealso:
 `FatalErrorHandler` protocol.
 */
public protocol RoxchatError {
    
    /**
     - returns:
     Parsed type of the error.
     */
    func getErrorType() -> FatalErrorType
    
    /**
     - returns:
     String representation of an error. Mostly useful if the error type is unknown.
     */
    func getErrorString() -> String
    
}

/**
 Roxchat service error types.
 - important:
 Mind that most of this errors causes session to destroy.
 */
public enum FatalErrorType {
    
    /**
     Indicates that the account in Roxchat service has been disabled (e.g. for non-payment). The error is unrelated to the user’s actions.
     Recommended response is to show the user an error message with a recommendation to try using the chat later.
     - important:
     Notice that the session will be destroyed if this error occured.
     */
    case accountBlocked
    
    @available(*, unavailable, renamed: "accountBlocked")
    case ACCOUNT_BLOCKED
    
    /**
     Indicates an expired authorization of a visitor.
     The recommended response is to re-authorize it and to re-create session object.
     - important:
     Notice that the session will be destroyed if this error occured.
     - seealso:
     `Roxchat.SessionBuilder.set(visitorFieldsJSONstring:)`
     `Roxchat.SessionBuilder.set(visitorFieldsJSONdata:)`
     */
    case providedVisitorFieldsExpired
    
    @available(*, unavailable, renamed: "providedVisitorFieldsExpired")
    case PROVIDED_VISITOR_FIELDS_EXPIRED
    
    /**
     Indicates the occurrence of an unknown error.
     Recommended response is to send an automatic bug report and show to a user an error message with the recommendation to try using the chat later.
     - important:
     Notice that the session will be destroyed if this error occured.
     - seealso:
     `RoxchatError.getErrorString()`
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
    /**
     Indicates that a visitor was banned by an operator and can't send messages to a chat anymore.
     Occurs when a user tries to open the chat or write a message after that.
     Recommended response is to show the user an error message with the recommendation to try using the chat later or explain to the user that it was blocked for some reason.
     - important:
     Notice that the session will be destroyed if this error occured.
     */
    case visitorBanned
    
    @available(*, unavailable, renamed: "visitorBanned")
    case VISITOR_BANNED
    
    /**
     Indicates a problem of your application authorization mechanism and is unrelated to the user’s actions.
     Occurs when trying to authorize a visitor with a non-valid signature.
     Recommended response is to send an automatic bug report and show the user an error message with the recommendation to try using the chat later.
     - important:
     Notice that the session will be destroyed if this error occured.
     - seealso:
     `Roxchat.SessionBuilder.set(visitorFieldsJSONstring:)`
     `Roxchat.SessionBuilder.set(visitorFieldsJSONdata:)`
     */
    case wrongProvidedVisitorHash
    
    @available(*, unavailable, renamed: "wrongProvidedVisitorHash")
    case WRONG_PROVIDED_VISITOR_HASH
    
}
