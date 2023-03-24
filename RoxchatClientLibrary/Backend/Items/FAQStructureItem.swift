
import Foundation

/**
 */
final class FAQStructureItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "id"
        case type = "type"
        case childs = "childs"
        case title = "title"
    }
    
    // MARK: - Properties
    private var id: String?
    private var title: String?
    private var type: RootType?
    private var children = [FAQStructureItem]()
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let title = jsonDictionary[JSONField.title.rawValue] as? String {
            self.title = title
        }
        
        if let type = jsonDictionary[JSONField.type.rawValue] as? String {
            self.type = toRootType(type: type)
        }
        
        if type == .item {
            if let id = jsonDictionary[JSONField.id.rawValue] as? String {
                self.id = id
            }
        } else {
            if let id = jsonDictionary[JSONField.id.rawValue] as? Int {
                self.id = String(id)
            }
        }
        
        if let childs = jsonDictionary[JSONField.childs.rawValue] as? [Any] {
            for child in childs {
                if let childValue = child as? [String: Any?] {
                    let childItem = FAQStructureItem(jsonDictionary: childValue)
                    children.append(childItem)
                }
            }
        }
    }
    
    private func toRootType(type: String) -> RootType? {
        switch type {
        case "item":
            return .item
        case "category":
            return .category
        default:
            return nil
        }
    }
    
}

extension FAQStructureItem: FAQStructure {
    func getID() -> String {
        guard let id = id else {
            RoxchatInternalLogger.shared.log(entry: "ID is nil in FAQStructureItem.\(#function)")
            return String()
        }
        return id
    }
    
    func getType() -> RootType {
        guard let type = type else {
            RoxchatInternalLogger.shared.log(entry: "Type is nil in FAQStructureItem.\(#function)")
            return .unknown
        }
        return type
    }
    
    func getChildren() -> [FAQStructure] {
        return children
    }
    
    func getTitle() -> String {
        guard let title = title else {
            RoxchatInternalLogger.shared.log(entry: "Title is nil in FAQStructureItem.\(#function)")
            return String()
        }
        return title
    }
    
    
    
}

extension FAQStructureItem: Equatable {
    
    // MARK: - Methods
    static func == (lhs: FAQStructureItem,
                    rhs: FAQStructureItem) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        
        return false
    }
    
}
