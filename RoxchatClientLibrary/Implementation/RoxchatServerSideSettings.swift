
import Foundation


public struct RoxchatServerSideSettings: Codable {
    public let accountConfig: AccountConfig
}

public struct AccountConfig: Codable {
    public let webAndMobileQuoting: Bool
    public let visitorMessageEditing: Bool
    public let maxVisitorUploadFileSize: Int
    public let allowedUploadFileTypes: String
    public let rateOperator: Bool
    public let showRateOperator: Bool?
    public let disablingMessageInputField: Bool?

    enum CodingKeys: String, CodingKey {
        case webAndMobileQuoting = "web_and_mobile_quoting"
        case visitorMessageEditing = "visitor_message_editing"
        case maxVisitorUploadFileSize = "max_visitor_upload_file_size"
        case allowedUploadFileTypes = "allowed_upload_file_types"
        case rateOperator = "rate_operator"
        case showRateOperator = "show_visitor_rate_operator_button"
        case disablingMessageInputField = "disabling_message_input_field"
    }
}
