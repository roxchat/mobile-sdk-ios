
import Foundation

extension Collection {
    
    /**
     Part or HMAC SHA256 generation system.
     */
    func batched(by size: Int) -> BatchedCollection<Self> {
        return BatchedCollection(base: self,
                                 size: size)
    }
    
}

/**
 Part or HMAC SHA256 generation system.
 */
struct BatchedCollection<Base: Collection>: Collection {
    
    typealias Index = BatchedCollectionIndex<Base>
    
    // MARK: - Properties
    let base: Base
    let size: Int
    
    // MARK: - Methods
    private func nextBreak(after idx: Base.Index) -> Base.Index {
        return (base.index(idx,
                           offsetBy: size,
                           limitedBy: base.endIndex) ?? base.endIndex)
    }
    
    var startIndex: Index {
        return Index(range: base.startIndex ..< nextBreak(after: base.startIndex))
    }
    
    var endIndex: Index {
        return Index(range: base.endIndex ..< base.endIndex)
    }
    
    func index(after idx: Index) -> Index {
        return Index(range: idx.range.upperBound ..< nextBreak(after: idx.range.upperBound))
    }
    
    subscript(idx: Index) -> Base.SubSequence {
        return base[idx.range]
    }
}

extension BatchedCollectionIndex: Comparable {
    
    // MARK: - Methods
    
    static func ==<Base>(lhs: BatchedCollectionIndex<Base>,
                         rhs: BatchedCollectionIndex<Base>) -> Bool {
        return (lhs.range.lowerBound == rhs.range.lowerBound)
    }
    
    static func <<Base>(lhs: BatchedCollectionIndex<Base>,
                        rhs: BatchedCollectionIndex<Base>) -> Bool {
        return (lhs.range.lowerBound < rhs.range.lowerBound)
    }
    
}

/**
 Part or HMAC SHA256 generation system.
 */
struct BatchedCollectionIndex<Base: Collection> {
    let range: Range<Base.Index>
}
