
import Foundation

class StickerItem {
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case stickerId = "stickerId"
    }
    
    // MARK: - Properties
    private let stickerId: Int
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        guard let stickerId = jsonDictionary[JSONField.stickerId.rawValue] as? Int else {
            return nil
        }
        
        self.stickerId = stickerId
    }
    
    init(stickerId: Int) {
        self.stickerId = stickerId
    }
    
    // MARK: - Methods
    func getStickerId() -> Int {
        return stickerId
    }
}
