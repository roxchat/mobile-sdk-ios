
import Foundation

/**
 Class that checks if session methods are called in appropriate conditions.
 */
class AccessChecker {
    
    // MARK: - Properties
    let thread: Thread
    let sessionDestroyer: SessionDestroyer
    let queue: DispatchQueue
    // MARK: - Initialization
    init(thread: Thread,
         sessionDestroyer: SessionDestroyer) {
        self.thread = thread
        self.sessionDestroyer = sessionDestroyer
        self.queue = DispatchQueue.current
    }
    
    // MARK: - Methods
    func checkAccess() throws {
        guard thread == Thread.current else {
            RoxchatInternalLogger.shared.log(
                entry: AccessError.invalidThread.localizedDescription)
            throw AccessError.invalidThread
        }
        
        guard self.queue == DispatchQueue.current else {
            RoxchatInternalLogger.shared.log(
                entry: AccessError.invalidSession.localizedDescription)
            throw AccessError.invalidSession
        }
        
        guard !sessionDestroyer.isDestroyed() else {
            RoxchatInternalLogger.shared.log(
                entry: AccessError.invalidSession.localizedDescription)
            throw AccessError.invalidSession
        }
    }
    
}

extension DispatchQueue {

    private struct QueueReference { weak var queue: DispatchQueue? }

    private static let key: DispatchSpecificKey<QueueReference> = {
        let key = DispatchSpecificKey<QueueReference>()
        setupSystemQueuesDetection(key: key)
        return key
    }()

    private static func _registerDetection(of queues: [DispatchQueue], key: DispatchSpecificKey<QueueReference>) {
        queues.forEach { $0.setSpecific(key: key, value: QueueReference(queue: $0)) }
    }

    private static func setupSystemQueuesDetection(key: DispatchSpecificKey<QueueReference>) {
        let queues: [DispatchQueue] = [
                                        .main,
                                        .global(qos: .background),
                                        .global(qos: .default),
                                        .global(qos: .unspecified),
                                        .global(qos: .userInitiated),
                                        .global(qos: .userInteractive),
                                        .global(qos: .utility)
                                    ]
        _registerDetection(of: queues, key: key)
    }
}


extension DispatchQueue {
    static func registerDetection(of queue: DispatchQueue) {
        _registerDetection(of: [queue], key: key)
    }

    static var currentQueueLabel: String? {
        current?.label
    }
    static var current: DispatchQueue! {
        getSpecific(key: key)?.queue
    }
}
