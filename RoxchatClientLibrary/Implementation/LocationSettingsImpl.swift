
import Foundation

/**
 Class that encapsulates various location settings received form server when initializing session.
 */
final class LocationSettingsImpl {
    
    // MARK: - Constants
    enum WMLocationSettingsKeychainKey: String {
        case hintsEnabled = "hints_enabled"
    }
    
    
    // MARK: - Properties
    private var hintsEnabled: Bool
    
    
    // MARK: - Initialization
    init(hintsEnabled: Bool) {
        self.hintsEnabled = hintsEnabled
    }
    
    
    // MARK: - Methods
    
    static func getFrom(userDefaults userDefaultsKey: String) -> LocationSettingsImpl {
        if let userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey) {
            if let hintsEnabled = userDefaults[WMLocationSettingsKeychainKey.hintsEnabled.rawValue] as? Bool {
                return LocationSettingsImpl(hintsEnabled: hintsEnabled)
            }
        }
        
        return LocationSettingsImpl(hintsEnabled: false)
    }
    
    func saveTo(userDefaults userDefaultsKey: String) {
        if var userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey) {
            userDefaults[WMLocationSettingsKeychainKey.hintsEnabled.rawValue] = hintsEnabled
            WMKeychainWrapper.standard.setDictionary(userDefaults,
                                      forKey: userDefaultsKey)
        }
        
        WMKeychainWrapper.standard.setDictionary([WMLocationSettingsKeychainKey.hintsEnabled.rawValue: hintsEnabled],
                                       forKey: userDefaultsKey)
    }
    
}

extension LocationSettingsImpl: Equatable {
    
    static func == (lhs: LocationSettingsImpl,
                    rhs: LocationSettingsImpl) -> Bool {
        return lhs.hintsEnabled == rhs.hintsEnabled
    }
    
}

extension LocationSettingsImpl: LocationSettings {
    
    func areHintsEnabled() -> Bool {
        return hintsEnabled
    }
    
}
