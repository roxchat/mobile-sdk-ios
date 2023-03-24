
import Foundation

/**
 Class that encapsulates asynchronous callbacks calling.
 */
final class ExecIfNotDestroyedFAQHandlerExecutor {
    
    // MARK: - Properties
    private let faqDestroyer: FAQDestroyer
    private let queue: DispatchQueue
    
    // MARK: - Initialization
    init(faqDestroyer: FAQDestroyer,
         queue: DispatchQueue) {
        self.faqDestroyer = faqDestroyer
        self.queue = queue
    }
    
    // MARK: - Methods
    func execute(task: DispatchWorkItem) {
        if !faqDestroyer.isDestroyed() {
            queue.async {
                if !self.faqDestroyer.isDestroyed() {
                    task.perform()
                }
            }
        }
    }
    
}
