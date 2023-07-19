
import Foundation

/**
 Class that encapsulates operator rating data.
 */
struct RatingItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case operatorID = "operatorId"
        case rating = "rating"
    }
    
    // MARK: - Properties
    private var operatorID: String
    private var rating: Int
    
    // MARK: - Initialization
    init?(jsonDictionary: [String : Any?]) {
        guard let operatorID = jsonDictionary[JSONField.operatorID.rawValue] as? Int,
            let rating = jsonDictionary[JSONField.rating.rawValue] as? Int else {
            return nil
        }
        
        self.operatorID = String(operatorID)
        self.rating = rating
    }
    
    // MARK: - Methods
    
    func getOperatorID() -> String {
        return operatorID
    }
    
    func getRating() -> Int {
        return rating
    }

    static func ==(rhs: RatingItem, lhs: RatingItem) -> Bool {
        return rhs.operatorID == lhs.operatorID && rhs.rating == lhs.rating
    }
}
