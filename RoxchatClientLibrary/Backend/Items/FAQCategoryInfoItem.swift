
import Foundation

/**
 */
final class FAQCategoryInfoItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "id"
        case title = "title"
    }
    
    // MARK: - Properties
    private var id: String?
    private var title: String?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? Int {
            self.id = String(id)
        }
        
        if let title = jsonDictionary[JSONField.title.rawValue] as? String {
            self.title = title
        }
    }
    
}

extension FAQCategoryInfoItem: FAQCategoryInfo {
    func getID() -> String {
        guard let id = id else {
            RoxchatInternalLogger.shared.log(entry: "ID is nil in FAQCategoryInfoItem.\(#function)")
            return String()
        }
        return id
    }
    
    func getTitle() -> String {
        guard let title = title else {
            RoxchatInternalLogger.shared.log(entry: "Title is nil in FAQCategoryInfoItem.\(#function)")
            return String()
        }
        return title
    }
    
}

extension FAQCategoryInfoItem: Equatable {
    
    // MARK: - Methods
    static func == (lhs: FAQCategoryInfoItem,
                    rhs: FAQCategoryInfoItem) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        
        return false
    }
    
}
