

import Foundation


/**
 Protocol that provides methods to handle not fatal errors are sent by Roxchat service.
 - seealso:
 `set(fatalErrorHandler:)` method of `SessionBuilder` class.
 */
public protocol NotFatalErrorHandler: class {
    
    /**
     This method is to be called when Roxchat service error is received.
     - important:
     Method called NOT FROM THE MAIN THREAD!
     - parameter error:
     Error type.
     */
    func on(error: RoxchatNotFatalError)
    
    /**
     This method is to be called when Roxchat service receive any data from server or connection error.
     - important:
     Method called NOT FROM THE MAIN THREAD!
     */
    func connectionStateChanged(connected: Bool)
    
}
