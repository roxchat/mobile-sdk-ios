
import Foundation
import RoxchatClientLibrary

let USER_DEFAULTS_NAME = "settings_demo"

enum WMSettingsKeychainKey: String {
    case accountName = "account_name"
    case location = "location"
    case pageTitle = "page_title"
    case userDataJson = "userDataJson"
}

// MARK: - Settings

final class Settings {
    
    // MARK: - Constants
    
    enum DefaultSettings: String {
        case accountName = "demo"
        case location = "mobile"
        case pageTitle = "iOS app"
        case userDataJson = ""
    }
    
    // MARK: - Properties
    
    static let shared = Settings()
    var accountName: String
    var location: String
    var pageTitle: String
    var userDataJson: String
    
    // MARK: - Initialization
    
    private init() {
        if let settings = WMKeychainWrapper.standard.dictionary(forKey: USER_DEFAULTS_NAME)
            as? [String: String] {
            self.accountName = settings[WMSettingsKeychainKey.accountName.rawValue] ??
                ""
            self.location = settings[WMSettingsKeychainKey.location.rawValue] ??
                DefaultSettings.location.rawValue
            self.pageTitle = settings[WMSettingsKeychainKey.pageTitle.rawValue] ??
                DefaultSettings.pageTitle.rawValue
            self.userDataJson = settings[WMSettingsKeychainKey.userDataJson.rawValue] ??
                DefaultSettings.userDataJson.rawValue
        } else {
            self.accountName = ""
            self.location = DefaultSettings.location.rawValue
            self.pageTitle = DefaultSettings.pageTitle.rawValue
            self.userDataJson = DefaultSettings.userDataJson.rawValue
        }
        validateData()
    }
    
    func validateData() {
        if !"https://\(accountName).rox.chat/".validateURLString() {
            self.accountName = ""
        }
    }
    
    // MARK: - Methods
    
    func save() {
        validateData()
        let settings = [
            WMSettingsKeychainKey.accountName.rawValue: accountName,
            WMSettingsKeychainKey.location.rawValue: location,
            WMSettingsKeychainKey.pageTitle.rawValue: pageTitle
        ]
        
        WMKeychainWrapper.standard.setDictionary(settings,
                                  forKey: USER_DEFAULTS_NAME)
    }
    
    func saveAccountName(accountName: String) {
        self.accountName = accountName
        let settings = [
            WMSettingsKeychainKey.accountName.rawValue: accountName
        ]
        
        WMKeychainWrapper.standard.setDictionary(settings,
                                  forKey: USER_DEFAULTS_NAME)
    }
    
    func getAccountName() -> String {
        if let settings = WMKeychainWrapper.standard.dictionary(forKey: USER_DEFAULTS_NAME)
            as? [String: String] {
            return settings[WMSettingsKeychainKey.accountName.rawValue] ?? accountName
        }
        
        return accountName
    }
}

