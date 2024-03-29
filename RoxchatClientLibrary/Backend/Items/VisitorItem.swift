
import UIKit

/**
 Internal representation of visitor information.
 */
struct VisitorItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case icon = "icon"
        case id = "id"
        case fields = "fields"
    }
    
    // MARK: - Properties
    private var icon: IconItem?
    private var id: String
    private var visitorFields: VisitorFieldsItem
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        guard let id = jsonDictionary[JSONField.id.rawValue] as? String,
            let visitorFieldsValue = jsonDictionary[JSONField.fields.rawValue] as? [String: Any?],
            let visitorFields = VisitorFieldsItem(jsonDictionary: visitorFieldsValue) else {
            return nil
        }
        
        self.id = id
        self.visitorFields = visitorFields
        
        if let iconValue = jsonDictionary[JSONField.icon.rawValue] as? [String : Any?] {
            icon = IconItem(jsonDictionary: iconValue)
        }
    }
    
    // MARK: - Methods
    
    func getIcon() -> IconItem? {
        return icon
    }
    
    func getID() -> String {
        return id
    }
    
    func getVisitorFields() -> VisitorFieldsItem {
        return visitorFields
    }
    
}

/**
 Representation of generated by server visitor avatar image of standard ones.
 */
struct IconItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case color = "color"
        case shape = "shape"
    }
    
    // MARK: - Properties
    private var color: UIColor
    private var shape: String
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        guard let colorString = jsonDictionary[JSONField.color.rawValue] as? String,
            let color = UIColor(hexString: colorString),
            let shape = jsonDictionary[JSONField.shape.rawValue] as? String else {
            return nil
        }
        
        self.color = color
        self.shape = shape
    }
    
    // MARK: - Methods
    
    func getColor() -> UIColor {
        return color
    }
    
    func getShape() -> String {
        return shape
    }
    
}

/**
 Internal representation of visitor fields.
 */
struct VisitorFieldsItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case email = "email"
        case name = "name"
        case phone = "phone"
    }
    
    // MARK: - Properties
    private var email: String?
    private var name: String
    private var phone: String?
    
    // MARK: - Initialization
    init?(jsonDictionary: [String : Any?]) {
        guard let name = jsonDictionary[JSONField.name.rawValue] as? String else {
            return nil
        }
        self.name = name
        
        if let email = jsonDictionary[JSONField.email.rawValue] as? String {
            self.email = email
        }
        
        if let phone = jsonDictionary[JSONField.phone.rawValue] as? String {
            self.phone = phone
        }
    }
    
    // MARK: - Methods
    
    func getName() -> String {
        return name
    }
    
    func getEmail() -> String? {
        return email
    }
    
    func getPhone() -> String? {
        return phone
    }
    
}
