
import Foundation
import UIKit
import CommonCrypto

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    public func validateURLString() -> Bool {
        for char in self {
            if char.isWhitespace || !char.isASCII {
                return false
            }
        }
        return NSURL(string: self) != nil
    }

}
