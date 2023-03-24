
import Foundation

/**
 */
final class LocationSettingsHolder {
    
    // MARK: - Properties
    private let locationSettings: LocationSettingsImpl
    private let userDefaultsKey: String
    
    // MARK: - Initialization
    init(userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
        locationSettings = LocationSettingsImpl.getFrom(userDefaults: userDefaultsKey)
    }
    
    // MARK: - Methods
    
    func getLocationSettings() -> LocationSettingsImpl {
        return locationSettings
    }
    
    func receiving(locationSettings: LocationSettingsImpl) -> Bool {
        if locationSettings != self.locationSettings {
            locationSettings.saveTo(userDefaults: userDefaultsKey)
            
            return true
        }
        
        return false
    }
    
}
