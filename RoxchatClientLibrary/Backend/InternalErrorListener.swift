
import Foundation

/**
 */
protocol InternalErrorListener {
    
    func on(error: String)
    
    func onNotFatal(error: NotFatalErrorType)
    
    func connectionStateChanged(connected: Bool)
    
}
