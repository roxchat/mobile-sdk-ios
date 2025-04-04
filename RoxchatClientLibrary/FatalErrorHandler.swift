

import Foundation


/**
 Protocol that provides methods to handle errors are sent by Roxchat service.
 - seealso:
 `set(fatalErrorHandler:)` method of `SessionBuilder` class.
 */
public protocol FatalErrorHandler: AnyObject {
    
    /**
     This method is to be called when Roxchat service error is received.
     - important:
     Method called NOT FROM THE MAIN THREAD!
     - parameter error:
     Error type.
     */
    func on(error: RoxchatError)
    
}
