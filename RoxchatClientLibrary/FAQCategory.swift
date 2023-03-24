

import Foundation

/**
 FAQ category contains pages with some information and subcategories.
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 */
public protocol FAQCategory {
    
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
    
    /**
     Every category contains items.
     - returns:
     List of category items.
     */
    func getItems() -> [FAQItem]
    
    /**
     Every category can be contains subcategories.
     - returns:
     List of categories that contains the item.
     */
    func getSubcategories() -> [FAQCategoryInfo]
}
