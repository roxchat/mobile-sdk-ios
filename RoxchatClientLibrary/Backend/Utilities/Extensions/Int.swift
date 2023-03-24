
import Foundation

extension Int {
    
    // MARK: - Methods
    /**
     Part or HMAC SHA256 generation system.
     */
    @_transparent
    func bytes(totalBytes: Int) -> Array<UInt8> {
        let valuePointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        valuePointer.pointee = self
        
        let bytesPointer = UnsafeMutablePointer<UInt8>(OpaquePointer(valuePointer))
        var bytes = Array<UInt8>(repeating: 0,
                                 count: totalBytes)
        let memoryLayoutSize = MemoryLayout<Int>.size
        let constraint = ((memoryLayoutSize < totalBytes) ? memoryLayoutSize : totalBytes)
        for j in 0 ..< constraint {
            bytes[(totalBytes - 1 - j)] = (bytesPointer + j).pointee
        }
        
        valuePointer.deinitialize(count: 1)
        valuePointer.deallocate()
        
        return bytes
    }
 
}
