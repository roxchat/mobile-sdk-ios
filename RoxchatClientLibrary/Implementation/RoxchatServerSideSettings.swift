
import Foundation


public struct RoxchatServerSideSettings: Codable {
    public let accountConfig: AccountConfig
}

// MARK: - AccountConfig
public struct AccountConfig: Codable {
    public let webAndMobileQuoting: Bool
    public let visitorMessageEditing: Bool
    public let maxVisitorUploadFileSize: Int
    public let allowedUploadFileTypes: String
    public let rateOperator: Bool
    public let showRateOperator: Bool?
    public let disablingMessageInputField: Bool?
    public let rateForm: String?
    public let ratedEntity: String?
    public let visitorSegment: String?
    public let showProcessingPersonalDataCheckbox: Bool?
    public let processingPersonalDataUrl: String?
//    let multilang, chattingTimer, googleAnalytics: Bool
//    let yandexMetrikaCounterID: JSONNull?
//    let teleport: Bool
//    let clientPHPURL: JSONNull?
//    let hideReferrer, forceVisitorHTTPS, visitorTracking, forceVisitorDisable: Bool
//    let visitorEnablingProbability: Int
//    let defaultLang: String
//    let showProcessingPersonalDataCheckbox, visitorWebsockets, visitorUploadFile: Bool
//    let operatorCheckStatusOnline: Int
//    let visitorHintsAPIEndpoint: JSONNull?
//    let fileURLExpiringTimeout: Int
//    let checkVisitorAuth, operatorStatusTimer, ,
//    let offlineChatProcessing, openChatInNewTabForMobile: Bool

    enum CodingKeys: String, CodingKey {
        case webAndMobileQuoting = "web_and_mobile_quoting"
        case visitorMessageEditing = "visitor_message_editing"
        case maxVisitorUploadFileSize = "max_visitor_upload_file_size"
        case allowedUploadFileTypes = "allowed_upload_file_types"
        case rateOperator = "rate_operator"
        case showRateOperator = "show_visitor_rate_operator_button"
        case disablingMessageInputField = "disabling_message_input_field"
        case rateForm = "rate_form"
        case ratedEntity = "rated_entity"
        case visitorSegment = "visitor_segment"
        case showProcessingPersonalDataCheckbox = "show_processing_personal_data_checkbox"
        case processingPersonalDataUrl = "processing_personal_data_url"
//        case multilang
//        case chattingTimer = "chatting_timer"
//        case googleAnalytics = "google_analytics"
//        case yandexMetrikaCounterID = "yandex_metrika_counter_id"
//        case teleport
//        case clientPHPURL = "client_php_url"
//        case hideReferrer = "hide_referrer"
//        case forceVisitorHTTPS = "force_visitor_https"
//        case visitorTracking = "visitor_tracking"
//        case forceVisitorDisable = "force_visitor_disable"
//        case visitorEnablingProbability = "visitor_enabling_probability"
//        case defaultLang = "default_lang"
//        case showProcessingPersonalDataCheckbox = "show_processing_personal_data_checkbox"
//        case visitorWebsockets = "visitor_websockets"
//        case visitorUploadFile = "visitor_upload_file"
//        case operatorCheckStatusOnline = "operator_check_status_online"
//        case visitorHintsAPIEndpoint = "visitor_hints_api_endpoint"
//        case fileURLExpiringTimeout = "file_url_expiring_timeout"
//        case checkVisitorAuth = "check_visitor_auth"
//        case operatorStatusTimer = "operator_status_timer"
//        case offlineChatProcessing = "offline_chat_processing"
//        case openChatInNewTabForMobile = "open_chat_in_new_tab_for_mobile"
    }
}
