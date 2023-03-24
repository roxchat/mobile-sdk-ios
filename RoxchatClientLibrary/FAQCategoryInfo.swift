

import Foundation

/**
 FAQCategory without children.
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 */
public protocol FAQCategoryInfo {
    
    /**
     Every category can be uniquefied by its ID.
     - returns:
     Unique ID of the category.
     */
    func getID() -> String
    
    /**
     - returns:
     Title of the category.
     */
    func getTitle() -> String
}
