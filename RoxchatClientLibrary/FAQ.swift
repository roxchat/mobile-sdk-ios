

import Foundation

/**
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 */
public protocol FAQ {
    
    /**
     Resumes FAQ networking.
     - important:
     FAQ is created as paused. To start using it firstly you should call this method.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `FAQAccessError.invalidFaq` if FAQ was destroyed.
     */
    func resume() throws
    
    /**
     Pauses FAQ networking.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if FAQ was destroyed.
     */
    func pause() throws
    
    /**
     Destroys FAQ. After that any FAQ methods are not available.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if FAQ was destroyed.
     */
    func destroy() throws
    
    /**
     Requests category. If nil is passed inside completion, there no category with this id.
     - seealso:
     `destroy()` method.
     `FAQCategory` protocol.
     - parameter id:
     Category ID.
     - parameter completionHandler:
     Completion to be called on category if method call succeeded.
     - parameter result:
     Resulting category if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     */
    func getCategory(id: String, completionHandler: @escaping (_ result: Result<FAQCategory, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Requests categories for app. If nil is passed inside completion, there no category with this id.
     - seealso:
     `destroy()` method.
     `FAQCategory` protocol.
     - parameter application:
     Application name.
     - parameter language:
     Language.
     - parameter departmentKey:
     Department key.
     - parameter completionHandler:
     Completion to be called on category if method call succeeded.
     - parameter result:
     Resulting category if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     */
    func getCategoriesForApplication(completionHandler: @escaping (_ result: Result<[String], FAQGetCompletionHandlerError>) -> Void)
    
     /**
     Requests category from cache. If nil is passed inside completion, there no category with this id in cache.
     - seealso:
     `destroy()` method.
     `FAQCategory` protocol.
     - parameter id:
     Category ID.
     - parameter completionHandler:
     Completion to be called on category if method call succeeded.
     - parameter result:
     Resulting category if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     */
    func getCachedCategory(id: String, completionHandler: @escaping (_ result: Result<FAQCategory, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Requests item. If nil is passed inside completion, there no item with this id.
     - seealso:
     `destroy()` method.
     `FAQItem` protocol.
     - parameter id:
     Item ID.
     - parameter openFrom:
     Item open from this source.
     - parameter completionHandler:
     Completion to be called on item if method call succeeded.
     - parameter result:
     Resulting item if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     */
    func getItem(id: String, openFrom: FAQItemSource?, completionHandler: @escaping (_ result: Result<FAQItem, FAQGetCompletionHandlerError>) -> Void)
    
    /**
    Requests item from cache. If nil is passed inside completion, there no item with this id.
    - seealso:
    `destroy()` method.
    `FAQItem` protocol.
    - parameter id:
    Item ID.
    - parameter openFrom:
    Item open from this source.
    - parameter completionHandler:
    Completion to be called on item if method call succeeded.
    - parameter result:
    Resulting item if method call succeeded.
    - throws:
    `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
    `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
    */
    func getCachedItem(id: String, openFrom: FAQItemSource?, completionHandler: @escaping (_ result: Result<FAQItem, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Requests structure. If nil is passed inside completion, there no structure with this id.
     - seealso:
     `destroy()` method.
     `FAQStructure` protocol.
     - parameter id:
     Structure ID.
     - parameter completionHandler:
     Completion to be called on structure if method call succeeded.
     - parameter result:
     Resulting structure if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     */
    func getStructure(id: String, completionHandler: @escaping (_ result: Result<FAQStructure, FAQGetCompletionHandlerError>) -> Void)
    
    /**
    Requests structure from cache. If nil is passed inside completion, there no structure with this id.
    - seealso:
    `destroy()` method.
    `FAQStructure` protocol.
    - parameter id:
    Structure ID.
    - parameter completionHandler:
    Completion to be called on structure if method call succeeded.
    - parameter result:
    Resulting structure if method call succeeded.
    - throws:
    `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
    `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
    */
    func getCachedStructure(id: String, completionHandler: @escaping (_ result: Result<FAQStructure, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Like selected FAQ item.
     - seealso:
     `destroy()` method.
     `FAQItem` protocol.
     - parameter item:
     FAQ item.
     */
    func like(item: FAQItem, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Dislike selected FAQ item.
     - seealso:
     `destroy()` method.
     `FAQItem` protocol.
     - parameter item:
     FAQ item.
     */
    func dislike(item: FAQItem, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Search categories by query.
     - seealso:
     `destroy()` method.
     `FAQCategory` protocol.
     - parameter query:
     Search word or phrase.
     - parameter category:
     Category for search.
     - parameter limitOfItems:
     A number of items will be returned (not more than this specified number).
     - parameter completionHandler:
     Completion to be called if method call succeeded.
     - parameter result:
     Resulting items array if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     */
    func search(query: String, category: String, limitOfItems: Int, completionHandler: @escaping (_ result: Result<[FAQSearchItem], FAQGetCompletionHandlerError>) -> Void)
}

/**
 Error types that can be throwed by FAQ methods.
 - seealso:
 `FAQ` methods.
 */
public enum FAQAccessError: Error {
    
    /**
     Error that is thrown if the method was called not from the thread the FAQ was created in.
     */
    case invalidThread
    
    @available(*, unavailable, renamed: "invalidThread")
    case INVALID_THREAD
    
    /**
     Error that is thrown if FAQ was destroyed.
     */
    case invalidFaq
    
    @available(*, unavailable, renamed: "invalidFaq")
    case INVALID_FAQ
}

/**
 Error types that can be throwed by FAQ methods.
 - seealso:
 `FAQ` methods.
 */
public enum FAQGetCompletionHandlerError: Error {
    case error
    
    @available(*, unavailable, renamed: "error")
    case ERROR
}

/**
 Item will be open from this source.
 - seealso:
 `FAQ` methods.
 */
public enum FAQItemSource {
    /**
    Item is opened from search.
    */
    case search
    
    @available(*, unavailable, renamed: "search")
    case SEARCH
    
    /**
    Item is opened from tree.
    */
    case tree
    
    @available(*, unavailable, renamed: "tree")
    case TREE
}
