
import Foundation

/**
 */
final class SessionDestroyer {
    
    // MARK: - Properties
    private lazy var actions = [() -> ()]()
    private var destroyed = false
    private var userDefaultsKey: String
    
    init(userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
    }
    
    // MARK: - Methods
    
    func add(action: @escaping () -> ()) {
        actions.append(action)
    }
    
    func getUserDefaulstKey() -> String {
        return userDefaultsKey
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
