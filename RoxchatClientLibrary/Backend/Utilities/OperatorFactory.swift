
import Foundation

/**
 Mapper class that is responsible for converting internal operator model objects to public ones.
 */
final class OperatorFactory {
    
    // MARK: - Properties
    var serverURLString: String
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    // MARK: - Methods
    func createOperatorFrom(operatorItem: OperatorItem?) -> OperatorImpl? {
        guard let operatorItem = operatorItem else { return nil }
        var avatarURL: String? = nil
        if let url = operatorItem.getAvatarURLString(),
            !url.isEmpty {
            avatarURL = serverURLString + url
        }
        return OperatorImpl(id: operatorItem.getID(),
                            name: operatorItem.getFullName(),
                            avatarURLString: avatarURL,
                            title: operatorItem.getTitle(),
                            info: operatorItem.getInfo())
    }
    
}
