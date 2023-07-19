
import Foundation

/**
 */
final class AccountConfigItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case hintsEndpoint = "visitor_hints_api_endpoint"
    }
    
    // MARK: - Properties
    private var hintsEndpoint: String?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let hintsEndpoint = jsonDictionary[JSONField.hintsEndpoint.rawValue] as? String {
            self.hintsEndpoint = hintsEndpoint
        }
    }
    
    // MARK: - Methods
    func getHintsEndpoint() -> String? {
        return hintsEndpoint
    }
}
