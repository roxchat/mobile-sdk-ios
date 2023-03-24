
import Foundation

/**
 Class used for handling storing cached completion handler in `MessageTrackerImpl` class.
 - seealso:
 `MessageTrackerImpl.cachedCompletionHandler`
 */
final class MessageHolderCompletionHandlerWrapper {
    
    // MARK: - Properties
    private var messageHolderCompletionHandler: ([Message]) -> ()
    
    // MARK: - Initialization
    init(completionHandler: @escaping ([Message]) -> ()) {
        messageHolderCompletionHandler = completionHandler
    }
    
    // MARK: - Methods
    func getCompletionHandler() -> ([Message]) -> () {
        return messageHolderCompletionHandler
    }
    
}
