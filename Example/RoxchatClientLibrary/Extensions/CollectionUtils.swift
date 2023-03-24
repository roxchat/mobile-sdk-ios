
import UIKit

extension Dictionary where Key: Equatable {
    func containsKey(keySearch: Key) -> Bool {
        return self.contains(where: { (key, _) in
            key == keySearch
        })
    }
}
