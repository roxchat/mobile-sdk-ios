
import Foundation

/**
 */
final class AccountConfigItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case hintsEndpoint = "visitor_hints_api_endpoint"
        case webAndMobileQuoting = "web_and_mobile_quoting"
        case visitorMessageEditing = "visitor_message_editing"
        case maxVisitorUploadFileSize = "max_visitor_upload_file_size"
        case allowedUploadFileTypes = "allowed_upload_file_types"
        case rateOperator = "rate_operator"
        case showRateOperator = "show_visitor_rate_operator_button"
        case disablingMessageInputField = "disabling_message_input_field"
    }
    
    // MARK: - Properties
    private var hintsEndpoint: String?
    private var webAndMobileQuoting: Bool?
    private var visitorMessageEditing: Bool?
    private var maxVisitorUploadFileSize: Int?
    private var allowedUploadFileTypes: [String]?
    private var rateOperator: Bool?
    private var showRateOperator: Bool?
    private var disablingMessageInputField: Bool?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let hintsEndpoint = jsonDictionary[JSONField.hintsEndpoint.rawValue] as? String {
            self.hintsEndpoint = hintsEndpoint
        }
        if let webAndMobileQuoting = jsonDictionary[JSONField.webAndMobileQuoting.rawValue] as? Bool {
            self.webAndMobileQuoting = webAndMobileQuoting
        }
        if let visitorMessageEditing = jsonDictionary[JSONField.visitorMessageEditing.rawValue] as? Bool {
            self.visitorMessageEditing = visitorMessageEditing
        }
        
        if let rateOperator = jsonDictionary[JSONField.rateOperator.rawValue] as? Bool {
            self.rateOperator = rateOperator
        }
        
        if let showRateOperator = jsonDictionary[JSONField.showRateOperator.rawValue] as? Bool {
            self.showRateOperator = showRateOperator
        }
        
        if let maxVisitorUploadFileSize = jsonDictionary[JSONField.maxVisitorUploadFileSize.rawValue] as? Int {
            if maxVisitorUploadFileSize != 0 {
                self.maxVisitorUploadFileSize = maxVisitorUploadFileSize
            } else {
                self.maxVisitorUploadFileSize = 10
            }
        }
        
        if let allowedUploadFileTypes = jsonDictionary[JSONField.allowedUploadFileTypes.rawValue] as? String {
            self.allowedUploadFileTypes = allowedUploadFileTypes.components(separatedBy: ", ")
        }
        
        if let disablingMessageInputField = jsonDictionary[JSONField.disablingMessageInputField.rawValue] as? Bool {
            self.disablingMessageInputField = disablingMessageInputField
        }
    }
    
    // MARK: - Methods
    func getHintsEndpoint() -> String? {
        return hintsEndpoint
    }
    
    func getWebAndMobileQuoting() -> Bool {
        return webAndMobileQuoting ?? true
    }
    
    func getVisitorMessageEditing() -> Bool {
        return visitorMessageEditing ?? true
    }
    
    func getMaxVisitorUploadFileSize() -> Int? {
        return maxVisitorUploadFileSize
    }
    
    func getAllowedUploadFileTypes() -> [String] {
        return allowedUploadFileTypes ?? []
    }
    
    func getAllowedRateOperator() -> Bool {
        return rateOperator ?? true
    }
    
    func getShowRateOperator() -> Bool {
        return showRateOperator ?? true
    }
    
    func getDisablingMessageInputField() -> Bool {
        return disablingMessageInputField ?? false
    }
}
