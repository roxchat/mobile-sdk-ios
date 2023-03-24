
import Foundation


public struct RoxchatServerSideSettings: Codable {
    public let accountConfig: AccountConfig
}

public struct AccountConfig: Codable {
    public let webAndMobileQuoting: Bool
    public let visitorMessageEditing: Bool

    enum CodingKeys: String, CodingKey {
        case webAndMobileQuoting = "web_and_mobile_quoting"
        case visitorMessageEditing = "visitor_message_editing"
    }
}
