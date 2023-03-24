
import Foundation

/**
 Class that encapsulates asynchronous callbacks calling.
 */
final class ExecIfNotDestroyedHandlerExecutor {
    
    // MARK: - Properties
    private let sessionDestroyer: SessionDestroyer
    private let queue: DispatchQueue
    
    // MARK: - Initialization
    init(sessionDestroyer: SessionDestroyer,
         queue: DispatchQueue) {
        self.sessionDestroyer = sessionDestroyer
        self.queue = queue
    }
    
    // MARK: - Methods
    func execute(task: DispatchWorkItem) {
        if !sessionDestroyer.isDestroyed() {
            self.queue.async {
                if !self.sessionDestroyer.isDestroyed() {
                    task.perform()
                }
            }
        }
    }
    
}
