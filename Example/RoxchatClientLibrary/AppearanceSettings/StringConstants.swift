
import Foundation

enum PopupAction: String {
    case reply = "Reply" // "Reply".localized
    case copy = "Copy" // "Copy".localized
    case edit = "Edit" // "Edit".localized
    case delete = "Delete" // "Delete".localized
    case like = "Like"
    case dislike = "Dislike"
}

enum OperatorAvatar: String {
    case placeholder = "NoAvatarURL"
    case empty = "GhostImage"
}
