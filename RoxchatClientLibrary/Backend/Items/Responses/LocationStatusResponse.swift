
import Foundation

/**
 */
final class LocationStatusResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case onlineOperators = "onlineOperators"
        case onlineStatus = "onlineStatus"
    }
    
    // MARK: - Properties
    private var onlineOperators: Bool?
    private var onlineStatus: String?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let onlineOperators = jsonDictionary[JSONField.onlineOperators.rawValue] as? Bool {
            self.onlineOperators = onlineOperators
        }
        
        if let onlineStatus = jsonDictionary[JSONField.onlineStatus.rawValue] as? String {
            self.onlineStatus = onlineStatus
        }
    }
    
    // MARK: - Methods
    
    func getOnlineOperator() -> Bool? {
        return onlineOperators
    }
    
    func getOnlineStatus() -> String? {
        return onlineStatus
    }
    
}
