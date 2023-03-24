
import UIKit

class WMDispatchQueueManager {
    static public let globalBackgroundSyncronizeDataQueue = DispatchQueue(label: "globalBackgroundSyncronizeSharedData")
}

@propertyWrapper
struct WMSynchronized<Value> {

    private var value: Value

    init(wrappedValue value: Value) {
        self.value = value
    }

    var wrappedValue: Value {
        get {
            return WMDispatchQueueManager.globalBackgroundSyncronizeDataQueue.sync {
                return value
            }
        }
        set {
            WMDispatchQueueManager.globalBackgroundSyncronizeDataQueue.sync() {
                self.value = newValue
            }
        }
    }
    
}

