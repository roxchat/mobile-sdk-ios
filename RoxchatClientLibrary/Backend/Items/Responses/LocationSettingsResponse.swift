
import Foundation

/**
 */
final class ServerSettingsResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case accountConfig = "accountConfig"
        case locationSettings = "locationSettings"
    }
    
    // MARK: - Properties
    private var accountConfig: AccountConfigItem?
    private var locationSettings: [String: Any?]?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let accountConfig = jsonDictionary[JSONField.accountConfig.rawValue] as? [String: Any?] {
            self.accountConfig = AccountConfigItem(jsonDictionary: accountConfig)
        }
        if let locationSettings = jsonDictionary[JSONField.locationSettings.rawValue] as? [String: Any?] {
            self.locationSettings = locationSettings
        }
    }
    
    // MARK: - Methods
    func getAccountConfig() -> AccountConfigItem? {
        return accountConfig
    }
    
    func getLocationSettings() -> [String: Any?] {
        return locationSettings ?? [:]
    }
    
}
