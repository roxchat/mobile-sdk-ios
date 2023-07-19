
import Foundation

/**
 Class that wraps `RoxchatAlert` into singleton pattern.
 First, one should call `setup(roxchatAlert:)` method with particular parameters, then it will be possible to use `RoxchatInternalAlert.shared`.
 - seealso:
 `RoxchatAlert`.
 */
final class RoxchatInternalAlert {
    
    // MARK: - Properties
    static let shared = RoxchatInternalAlert()
    private static let setup = RoxchatInternalAlertParametersHelper()
    
    // MARK: - Initialization
    private init() {
        // Needed for singleton pattern.
    }
    
    // MARK: - Methods
    
    class func setup(roxchatAlert: RoxchatAlert?) {
        RoxchatInternalAlert.setup.roxchatAlert = roxchatAlert
    }
    
    func present(title: RoxchatAlertTitle, message: RoxchatAlertMessage) {
        RoxchatInternalAlert.setup.roxchatAlert?.present(title: title, message: message)
    }
}

/**
 Helper class for `RoxchatInternalAlert` singleton instance setup.
 - seealso:
 `RoxchatInternalAlert`.
 */
final class RoxchatInternalAlertParametersHelper {
    
    // MARK: - Properties
    weak var roxchatAlert: RoxchatAlert?
    
}
