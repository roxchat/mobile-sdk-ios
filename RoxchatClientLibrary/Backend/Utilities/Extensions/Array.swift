
import Foundation

extension Array where Element == UInt8 {
    
    // MARK: - Methods
    /**
     Part or HMAC SHA256 generation system.
     */
    public func toHexString() -> String {
        return `lazy`.reduce("") {
            var s = String($1,
                           radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            
            return $0 + s
        }
    }
}
