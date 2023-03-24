
import UIKit

class WMWeakReferenseContainer<T>: Hashable {
    private weak var value: AnyObject?

    init(_ value: T) {
        self.value = value as AnyObject
    }
    
    func setValue(_ value: T?) {
        self.value = value as AnyObject
    }
    
    func getValue() -> T? {
        return value as? T
    }
    
    static func == (lhs: WMWeakReferenseContainer, rhs: WMWeakReferenseContainer) -> Bool {
        return ObjectIdentifier(lhs.value ?? lhs) == ObjectIdentifier(rhs.value ?? rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine( ObjectIdentifier(value ?? self).hashValue)
    }
}
