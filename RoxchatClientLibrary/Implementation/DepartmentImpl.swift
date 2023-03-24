
import Foundation

final class DepartmentImpl: Department {
    
    // MARK: - Properties
    private let departmentOnlineStatus: DepartmentOnlineStatus
    private let key: String
    private let name: String
    private let order: Int
    private var localizedNames: [String: String]?
    private var logoURL: URL?
    
    // MARK: - Initialization
    init(key: String,
         name: String,
         departmentOnlineStatus: DepartmentOnlineStatus,
         order: Int,
         localizedNames: [String: String]? = nil,
         logo: URL? = nil) {
        self.key = key
        self.name = name
        self.departmentOnlineStatus = departmentOnlineStatus
        self.order = order
        self.localizedNames = localizedNames
        self.logoURL = logo
    }
    
    // MARK: - Methods
    // MARK: Department protocol methods
    
    func getKey() -> String {
        return key
    }
    
    func getName() -> String {
        return name
    }
    
    func getDepartmentOnlineStatus() -> DepartmentOnlineStatus {
        return departmentOnlineStatus
    }
    
    func getOrder() -> Int {
        return order
    }
    
    func getLocalizedNames() -> [String: String]? {
        return localizedNames
    }
    
    func getLogoURL() -> URL? {
        return logoURL
    }
    
}
