
import Foundation

/**
 */
public protocol RoxchatSession: class {
    
    /**
     Resumes session networking.
     - important:
     Session is created as paused. To start using it firstly you should call this method.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func resume() throws
    
    /**
     Pauses session networking.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func pause() throws
    
    /**
     Destroys session. After that any session methods are not available.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func destroy() throws
    
    /**
     Destroys session, performing a cleanup.. After that any session methods are not available.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func destroyWithClearVisitorData() throws
    
    /**
     - returns:
     A `MessageStream` object attached to this session. Each invocation of this method returns the same object.
     */
    func getStream() -> MessageStream
    
    /**
     Changes location without creating a new session.
     - parameter location:
     New location name.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - seealso:
     `FatalErrorHandler`.
     */
    func change(location: String) throws
    
    /**
     This method allows to manually set device token after the session is created.
     Example that shows how to change device token for the proper formatted one:
     `let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()`
     - parameter deviceToken:
     Device token in hexadecimal format and without any spaces and service symbols.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func set(deviceToken: String) throws
    
}

/**
 Error types that can be throwed by MessageStream methods.
 - seealso:
 `RoxchatSession` and `MessageStream` methods.
 */
public enum AccessError: Error {
    
    /**
     Error that is thrown if the method was called not from the thread the RoxchatSession was created in.
     */
    case invalidThread
    
    @available(*, unavailable, renamed: "invalidThread")
    case INVALID_THREAD
    
    /**
     Error that is thrown if RoxchatSession was destroyed.
     */
    case invalidSession
    
    @available(*, unavailable, renamed: "invalidSession")
    case INVALID_SESSION
}
