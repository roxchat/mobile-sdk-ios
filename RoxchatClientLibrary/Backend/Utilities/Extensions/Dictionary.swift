
import Foundation

extension Dictionary {
    
    // MARK: - Methods
    /**
     Build string representation of HTTP parameter dictionary of keys and objects.
     This percent escapes in compliance with RFC 3986.
     - important:
     Supports only non-optional String keys and values.
     - seealso:
     http://www.ietf.org/rfc/rfc3986.txt
     - returns:
     String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped.
     */
    func stringFromHTTPParameters() -> String {
        let parameterArray = map { (key, value) -> String in
            guard let key = key as? String else {
                    RoxchatInternalLogger.shared.log(entry: "Key has incorrect type or nil in extension Dictionary.\(#function)")
                    return String()
            }
            
            return getPercentEscapedString(forKey: key, value: value)
        }
        
        return parameterArray.joined(separator: "&")
    }
    
    func jsonFromHTTPParameters() -> String {
        let parameterArray = map { (key, value) -> String in
            guard let key = key as? String else {
                    RoxchatInternalLogger.shared.log(entry: "Key has incorrect type or nil in extension Dictionary.\(#function)")
                    return String()
            }
            
            return getPercentEscapedString(forKey: key, value: value, isPartOfJSON: true)
        }
        
        return "{" + parameterArray.joined(separator: ",") + "}"
    }
    
    private func getPercentEscapedString<T>(forKey key: String, value: T?, isPartOfJSON: Bool = false) -> String {
        guard let value = value else {
            RoxchatInternalLogger.shared.log(entry: "Value is nil in extension Dictionary.\(#function)")
            return String()
        }
        
        var stringValue: String
        switch value {
        case is String,
             is Int,
             is Int64,
             is Double:
            stringValue = "\(value)"
        case is Bool:
            stringValue = (value as? Bool ?? false) ? "1" : "0"
        default:
            RoxchatInternalLogger.shared.log(entry: "Value has incorrect type in extension Dictionary.\(#function)")
            return String()
        }
        
        if isPartOfJSON {
            stringValue = stringValue.replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(key)\"=\"\(stringValue)\""
        }
        
        guard let percentEscapedKey = key.addingPercentEncodingForURLQueryValue() else {
            RoxchatInternalLogger.shared.log(entry: "Adding Percent Encoding For URL Query Value to Key failure in Extension Dictionary.\(#function)")
            return "\(key)=\(stringValue)"
        }
        
        guard let percentEscapedValue = stringValue.addingPercentEncodingForURLQueryValue() else {
            RoxchatInternalLogger.shared.log(entry: "Adding Percent Encoding For URL Query Value to Value failure in Extension Dictionary.\(#function)")
            return "\(key)=\(stringValue)"
        }
        
        return "\(percentEscapedKey)=\(percentEscapedValue)"
    }
    
}
