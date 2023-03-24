
import Foundation

/**
 Mapper class that is responsible for converting internal department model objects to public ones.
 */
final class DepartmentFactory {
    
    // MARK: - Properties
    let serverURLString: String
    
    // MARK - Initialization
    init(serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    // MARK: - Methods
    
    func convert(departmentItem: DepartmentItem) -> DepartmentImpl {
        var fullLogoURL: URL?
        if let logoURLString = departmentItem.getLogoURLString() {
            fullLogoURL = URL(string: serverURLString + logoURLString)
        }
        
        return DepartmentImpl(key: departmentItem.getKey(),
                              name: departmentItem.getName(),
                              departmentOnlineStatus: publicState(ofDepartmentOnlineStatus: departmentItem.getOnlineStatus()),
                              order: departmentItem.getOrder(),
                              localizedNames: departmentItem.getLocalizedNames(),
                              logo: fullLogoURL)
    }
    
    // MARK: Private methods
    private func publicState(ofDepartmentOnlineStatus departmentOnlineStatus: DepartmentItem.InternalDepartmentOnlineStatus) -> DepartmentOnlineStatus {
        switch departmentOnlineStatus {
        case .busyOffline:
            return .busyOffline
        case .busyOnline:
            return .busyOnline
        case .offline:
            return .offline
        case .online:
            return .online
        case .unknown:
            return .unknown
        }
    }
    
}
