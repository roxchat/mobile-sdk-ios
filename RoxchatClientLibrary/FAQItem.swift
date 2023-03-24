

import Foundation

/**
 FAQ page with some information.
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 */
public protocol FAQItem {
    
    /**
     Every item can be uniquefied by its ID.
     - returns:
     Unique ID of the item.
     */
    func getID() -> String
    
    /**
     Every item can be contained in different categories.
     - returns:
     List of categories that contains the item.
     */
    func getCategories() -> [String]
    
    /**
     - returns:
     Title of the item.
     */
    func getTitle() -> String
    
    /**
     - returns:
     List of item tags.
     */
    func getTags() -> [String]
    
    /**
     - returns:
     Item content.
     */
    func getContent() -> String
    
    /**
     - returns:
     Like count of the item.
     */
    func getLikeCount() -> Int
    
    
    /**
     - returns:
     Dislike count of the item.
     */
    func getDislikeCount() -> Int
    
    /**
     - returns:
     User rate.
     */
    func getUserRate() -> UserRate
}

/**
 Item can be liked or dislike.
 - seealso:
 `FAQStructure.getType()`
 */
public enum UserRate {
    /**
     Item is liked.
     */
    case like
    
    @available(*, unavailable, renamed: "like")
    case LIKE
    
    /**
     Item is disliked.
     */
    case dislike
    
    @available(*, unavailable, renamed: "dislike")
    case DISLIKE
    
    /**
     Item isn't rated.
     */
    case noRate
    
    @available(*, unavailable, renamed: "noRate")
    case NO_RATE
    
}

/**
 FAQ page with some information from search.
 */
public protocol FAQSearchItem {
    /**
     Every item can be uniquefied by its ID.
     - returns:
     Unique ID of the item.
     */
    func getID() -> String
    
    /**
     - returns:
     Title of the item.
     */
    func getTitle() -> String
    
    /**
     - returns:
     Search score. A larger score is better than a smaller score.
     */
    func getScore() -> Double
}
