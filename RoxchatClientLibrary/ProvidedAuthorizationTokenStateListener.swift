
import Foundation

/**
 When client provides custom visitor authorization mechanism, it can be realised by providing custom authorization token which is used instead of visitor fields.
 When provided authorization token is generated (or passed to session by client app), `update(providedAuthorizationToken:)` method is called. This method call indicates that client app must send provided authorisation token to its server which is responsible to send it to Roxchat service.
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 */
public protocol ProvidedAuthorizationTokenStateListener: AnyObject {
    
    /**
     Method is called in two cases:
     1. Provided authorization token is genrated (or set by client app) and must be sent to client server which is responsible to send it to Roxchat service.
     2. Passed provided authorization token is not valid. Provided authorization token can be invalid if Roxchat service did not receive it from client server yet.
     When this method is called, client server must send provided authorization token to Roxchat service.
     - parameter providedAuthorizationToken:
     Provided authorization token which corresponds to session.
     - seealso:
     `set(providedAuthorizationTokenStateListener:providedAuthorizationToken:)`
     */
    func update(providedAuthorizationToken: String)
    
}
