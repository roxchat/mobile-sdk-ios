
import Foundation

/**
 Protocol that provides methods for implementing custom RoxchatClientLibrary network requests logging.
 It can be useful for debugging production releases if debug logs are not available.
 */
public protocol RoxchatLogger: AnyObject {
    
    /**
     Method which is called after new RoxchatClientLibrary network request log entry came out.
     - parameter entry:
     New RoxchatClientLibrary network request log entry.
     */
    func log(entry: String)
    
}
