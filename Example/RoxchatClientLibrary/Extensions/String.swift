
import Foundation
import UIKit
import CommonCrypto

extension String {
    
    func MD5() -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = self.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    // MARK: - Properties
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from!),
                       length: utf16.distance(from: from!, to: to!))
    }
    
    func substring(_ nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    func addHttpsPrefix() -> String {
        if self.lowercased().hasPrefix("https://") || self.lowercased().hasPrefix("http://") {
            return self
        }
        return "https://" + self
    }
    
    static func unwarpOrEmpty(_ str: String?) -> String {
        if let str = str {
            return str
        }
        return ""
    }
}

extension String {
    
    // MARK: - Methods
    public func decodePercentEscapedLinksIfPresent() -> String {
        var convertedString = String()
        
        let checkingTypes: NSTextCheckingResult.CheckingType = [.link]
        if let linksDetector = try? NSDataDetector(types: checkingTypes.rawValue) {
            
            // swiftlint:disable legacy_constructor
            let linkMatches = linksDetector.matches(in: self,
                                                    range: NSMakeRange(0,
                                                                       self.count))
            // swiftlint:enable legacy_constructor
            if !linkMatches.isEmpty {
                var position = 0
                
                for linkMatch in linkMatches {
                    let linkMatchRange = linkMatch.range
                    if let url = linkMatch.url {
                        let beforeLinkStringSliceRangeStart = self.index(self.startIndex,
                                                                         offsetBy: position)
                        let beforeLinkStringSliceRangeEnd = self.index(self.startIndex,
                                                                       offsetBy: linkMatchRange.location)
                        let beforeLinkStringSlice = String(self[beforeLinkStringSliceRangeStart ..< beforeLinkStringSliceRangeEnd])
                        convertedString += beforeLinkStringSlice
                        
                        position = linkMatchRange.location + linkMatchRange.length
                        
                        let urlString = url.absoluteString.removingPercentEncoding
                        if let urlString = urlString {
                            convertedString += urlString
                        } else {
                            let linkStringSliceRangeStart = self.index(self.startIndex,
                                                                       offsetBy: linkMatchRange.location)
                            let linkStringSliceRangeEnd = self.index(self.startIndex,
                                                                     offsetBy: linkMatchRange.length)
                            convertedString += String(self[linkStringSliceRangeStart ..< linkStringSliceRangeEnd])
                        }
                    }
                }
                
                let closingStringSliceRangeStart = self.index(self.startIndex,
                                                              offsetBy: position)
                let closingStringSliceRangeEnd = self.index(self.startIndex,
                                                            offsetBy: self.count)
                let closingStringSlice = String(self[closingStringSliceRangeStart ..< closingStringSliceRangeEnd])
                convertedString += closingStringSlice
            } else {
                return self
            }
        }
        
        return convertedString
    }
    
    public func trimWhitespacesIn() -> String {
        let components = self.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
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
