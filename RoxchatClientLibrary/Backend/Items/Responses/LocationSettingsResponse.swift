
import Foundation

/**
 */
final class LocationSettingsResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case locationSettings = "locationSettings"
    }
    
    // MARK: - Properties
    private var locationSettings: [String: Any?]?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let locationSettings = jsonDictionary[JSONField.locationSettings.rawValue] as? [String: Any?] {
            self.locationSettings = locationSettings
        }
    }
    
    // MARK: - Methods
    func getLocationSettings() -> [String: Any?] {
        return locationSettings ?? [:]
    }
    
}
