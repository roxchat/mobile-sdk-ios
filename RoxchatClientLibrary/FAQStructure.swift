

import Foundation

/**
 Category subtree.
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 */
public protocol FAQStructure {
    /**
     Every structure has root.
     - returns:
     Unique ID of the tree root.
     */
    func getID() -> String
    
    /**
     - returns:
     Root type.
     */
    func getType() -> RootType
    
    /**
     - returns:
     Root's children.
     */
    func getChildren() -> [FAQStructure]
    
    /**
     - returns:
     Root title.
     */
    func getTitle() -> String
}

/**
 Supported structure root types.
 - seealso:
 `FAQStructure.getType()`
 */
public enum RootType {
    /**
     Root is category.
     */
    case category
    
    @available(*, unavailable, renamed: "category")
    case CATEGORY
    
    /**
     Root is item.
     */
    case item
    
    @available(*, unavailable, renamed: "item")
    case ITEM
    
    /**
    Unknown root type.
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
}
