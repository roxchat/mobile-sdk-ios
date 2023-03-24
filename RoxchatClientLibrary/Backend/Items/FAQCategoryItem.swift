
import Foundation

/**
 */
final class FAQCategoryItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "categoryid"
        case title = "title"
        case childs = "childs"
    }
    
    // MARK: - Properties
    private var id: String?
    private var title: String?
    private var children = [Child]()
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? Int {
            self.id = String(id)
        }
        
        if let title = jsonDictionary[JSONField.title.rawValue] as? String {
            self.title = title
        }
        
        if let childs = jsonDictionary[JSONField.childs.rawValue] as? [Any] {
            for child in childs {
                if let childValue = child as? [String: Any?] {
                    let childItem = Child(jsonDictionary: childValue)
                    children.append(childItem)
                }
            }
        }
    }
    
}

extension FAQCategoryItem: FAQCategory {
    func getID() -> String {
        guard let id = id else {
            RoxchatInternalLogger.shared.log(entry: "ID is nil in FAQCategoryItem.\(#function)")
            return String()
        }
        return id
    }
    
    func getTitle() -> String {
        guard let title = title else {
            RoxchatInternalLogger.shared.log(entry: "Title is nil in FAQCategoryItem.\(#function)")
            return String()
        }
        return title
    }
    
    func getItems() -> [FAQItem] {
        var items = [FAQItem]()
        for child in children {
            if child.type == .item,
                let data = child.data as? FAQItemItem {
                items.append(data)
            }
        }
        return items
    }
    
    func getSubcategories() -> [FAQCategoryInfo] {
        var subCategories = [FAQCategoryInfo]()
        for child in children {
            if child.type == .category,
                let data = child.data as? FAQCategoryInfoItem {
                subCategories.append(data)
            }
        }
        return subCategories
    }
    
    
}

extension FAQCategoryItem: Equatable {
    
    // MARK: - Methods
    static func == (lhs: FAQCategoryItem,
                    rhs: FAQCategoryItem) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        
        return false
    }
    
}

final class Child {
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case type = "type"
        case data = "data"
    }
    
    // MARK: - Properties
    public var type: RootType?
    public var data: Any?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let type = jsonDictionary[JSONField.type.rawValue] as? String {
            switch type {
            case "item":
                self.type = .item
                if let data = jsonDictionary[JSONField.data.rawValue] as? [String: Any?] {
                    self.data = FAQItemItem(jsonDictionary: data)
                }
                break
            case "category":
                self.type = .category
                if let data = jsonDictionary[JSONField.data.rawValue] as? [String: Any?]  {
                    self.data = FAQCategoryInfoItem(jsonDictionary: data)
                }
                break
            default:
                self.type = .unknown
            }
        }
    }
}
