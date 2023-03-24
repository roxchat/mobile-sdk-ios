
import Foundation

/**
 Abstracts a chat operator.
 - seealso:
 `MessageStream.getCurrentOperator()`
 */
public protocol Operator {
    
    /**
     - returns:
     Unique ID of the operator.
     - seealso:
     `MessageStream.rateOperatorWith(id:byRate:completionHandler:)`
     `MessageStream.getLastRatingOfOperatorWith(id:)`
     */
    func getID() -> String
    
    /**
     - returns:
     Display name of the operator.
     */
    func getName() -> String
    
    /**
     - returns:
     URL of the operator’s avatar or `nil` if does not exist.
     */
    func getAvatarURL() -> URL?
    
    /**
     - returns:
     Display operator title.
     */
    func getTitle() -> String?
    
    /**
     - returns:
     Display operator additional Information.
     */
    func getInfo() -> String?
}
