
import Foundation

/**
 Public Roxchat service error representation.
 */
final class RoxchatErrorImpl: RoxchatError {
    
    // MARK: - Properties
    private var errorType: FatalErrorType
    private var errorString: String?
    
    // MARK: - Initialization
    init(errorType: FatalErrorType,
         errorString: String?) {
        self.errorType = errorType
        self.errorString = errorString
    }
    
    // MARK: - Methods
    // MARK: RoxchatError protocol methods
    
    func getErrorType() -> FatalErrorType {
        return errorType
    }
    
    func getErrorString() -> String {
        return (errorString ?? String(describing: errorType))
    }
    
}
