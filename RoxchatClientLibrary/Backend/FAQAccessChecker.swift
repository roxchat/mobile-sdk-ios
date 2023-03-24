
import Foundation

/**
 Class that checks if FAQ methods are called in appropriate conditions.
 */
class FAQAccessChecker {
    
    // MARK: - Properties
    let thread: Thread
    let faqDestroyer: FAQDestroyer
    
    // MARK: - Initialization
    init(thread: Thread,
         faqDestroyer: FAQDestroyer) {
        self.thread = thread
        self.faqDestroyer = faqDestroyer
    }
    
    // MARK: - Methods
    func checkAccess() throws {
        guard thread == Thread.current else {
            throw FAQAccessError.invalidThread
        }
        
        guard !faqDestroyer.isDestroyed() else {
            throw FAQAccessError.invalidFaq
        }
    }
    
}
