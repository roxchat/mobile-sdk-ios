
import Foundation

/**
 */
final class FAQDestroyer {
    
    // MARK: - Properties
    private lazy var actions = [() -> ()]()
    private var destroyed = false
    
    // MARK: - Methods
    
    func add(action: @escaping () -> ()) {
        actions.append(action)
    }
    
    func destroy() {
        if !destroyed {
            destroyed = true
            
            for action in actions {
                action()
            }
            actions.removeAll(keepingCapacity: false)
        }
    }
    
    func isDestroyed() -> Bool {
        return destroyed
    }
    
}
