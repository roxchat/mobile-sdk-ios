
import Foundation

/**
 Class that encapsulates chat operator data, received from server.
 */
struct OperatorItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case avatarURLString = "avatar"
        case departmentKeys = "departmentKeys"
        case id = "id"
        case fullName = "fullname"
        case info = "additionalInfo"
        case title = "title"
    }
    
    // MARK: - Properties
    private var avatarURLString: String?
    private var id: String
    private var fullName: String
    private var info: String?
    private var title: String?
    
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? Int {
            self.id = String(id)
        } else {
            return nil
        }
        
        if let fullName = jsonDictionary[JSONField.fullName.rawValue] as? String {
            self.fullName = fullName
        } else {
            return nil
        }
        
        if let avatarURLString = jsonDictionary[JSONField.avatarURLString.rawValue] as? String {
            self.avatarURLString = avatarURLString
        }

        if let info = jsonDictionary[JSONField.info.rawValue] as? String {
            self.info = info
        }
        
        if let title = jsonDictionary[JSONField.title.rawValue] as? String {
            self.title = title
        }
    }
    
    // MARK: - Methods
    
    func getID() -> String {
        return id
    }
    
    func getFullName() -> String {
        return fullName
    }
    
    func getAvatarURLString() -> String? {
        return avatarURLString
    }
    
    func getInfo() -> String? {
        return info
    }
    
    func getTitle() -> String? {
        return title
    }
    
}
