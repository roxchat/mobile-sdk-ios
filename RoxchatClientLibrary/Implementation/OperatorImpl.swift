
import Foundation

/**
 Internal representation of a chat operator data.
 */
struct OperatorImpl: Operator {
    
    // MARK: - Properties
    private let id: String
    private let name: String
    private let avatarURLString: String?
    private let title: String?
    private let info: String?
    
    // MARK: - Initialization
    init(id: String,
         name: String,
         avatarURLString: String? = nil,
         title: String? = nil,
         info: String? = nil) {
        self.id = id
        self.name = name
        self.avatarURLString = avatarURLString
        self.title = title
        self.info = info
    }
    
    // MARK: - Methods
    // MARK: Operator protocol methods
    
    func getID() -> String {
        return id
    }
    
    func getName() -> String {
        return name
    }
    
    func getAvatarURL() -> URL? {
        guard let avatarURLString = avatarURLString else {
            return nil
        }
        
        return URL(string: avatarURLString)
    }
    
    func getTitle() -> String? {
        return title
    }
    
    func getInfo() -> String? {
        return info
    }
}

extension OperatorImpl: Equatable {
    
    // MARK: - Methods
    static func == (lhs: OperatorImpl,
                    rhs: OperatorImpl) -> Bool {
        return ((lhs.id == rhs.id)
            && (lhs.name == rhs.name))
            && (lhs.avatarURLString == rhs.avatarURLString)
    }
    
}
