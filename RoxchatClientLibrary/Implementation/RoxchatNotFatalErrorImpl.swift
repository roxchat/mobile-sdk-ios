
import Foundation

/**
 Public Roxchat service not fatal error representation.
 */
final class RoxchatNotFatalErrorImpl: RoxchatNotFatalError {
    
    // MARK: - Properties
    private var errorType: NotFatalErrorType
    
    // MARK: - Initialization
    init(errorType: NotFatalErrorType) {
        self.errorType = errorType
    }
    
    // MARK: - Methods
    // MARK: RoxchatError protocol methods
    
    func getErrorType() -> NotFatalErrorType {
        return errorType
    }
    
    func getErrorString() -> String {
        return String(describing: errorType)
    }
    
}
