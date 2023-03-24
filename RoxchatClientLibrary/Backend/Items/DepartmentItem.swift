
import Foundation

/**
 Encapsulates internal representation of single department.
 */
final class DepartmentItem {
    
    // MARK: - Constants
    
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case key = "key"
        case localizedNames = "localeToName"
        case name = "name"
        case onlineStatus = "online"
        case order = "order"
        case logo = "logo"
    }
    
    enum InternalDepartmentOnlineStatus: String {
        case busyOffline = "busy_offline"
        case busyOnline = "busy_online"
        case offline = "offline"
        case online = "online"
        case unknown
    }
    
    // MARK: - Properties
    private let key: String
    private let name: String
    private let onlineStatus: InternalDepartmentOnlineStatus
    private let order: Int
    private var localizedNames: [String: String]?
    private var logo: String?
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        guard let key = jsonDictionary[JSONField.key.rawValue] as? String,
            let name = jsonDictionary[JSONField.name.rawValue] as? String,
            let onlineStatusString = jsonDictionary[JSONField.onlineStatus.rawValue] as? String,
            let order = jsonDictionary[JSONField.order.rawValue] as? Int else {
            return nil
        }
        
        self.key = key
        self.name = name
        self.onlineStatus = InternalDepartmentOnlineStatus(rawValue: onlineStatusString) ?? .unknown
        self.order = order
        
        if let logoURLString = jsonDictionary[JSONField.logo.rawValue] as? String {
            self.logo = logoURLString
        }
        
        if let localizedNames = jsonDictionary[JSONField.localizedNames.rawValue] as? [String: String] {
            self.localizedNames = localizedNames
        }
    }
    
    // MARK: - Methods
    
    func getKey() -> String {
        return key
    }
    
    func getName() -> String {
        return name
    }
    
    func getOnlineStatus() -> InternalDepartmentOnlineStatus {
        return onlineStatus
    }
    
    func getOrder() -> Int {
        return order
    }
    
    func getLocalizedNames() -> [String: String]? {
        return localizedNames
    }
    
    func getLogoURLString() -> String? {
        return logo
    }
    
}
