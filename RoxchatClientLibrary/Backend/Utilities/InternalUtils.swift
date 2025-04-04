
import Foundation

/**
 Various SDK utilities.
 */
final class InternalUtils {
    static let domains = ["rox.chat", "rox2.chat"]
    
    // MARK: - Methods
    
    static func changeDomainFor(url: String) -> String {
        for (index, domain) in domains.enumerated() {
            if url.contains(domain) {
                return url.replacingOccurrences(of: domains[index], with: domains[(index + 1) % domains.count])
            }
        }
        return url
    }
    
    static func createServerURLStringBy(accountName: String) -> String {
        var serverURLstring = accountName
        
        if let _ = serverURLstring.range(of: "://") {
            if (serverURLstring.last ?? Character(" ")) == "/" {
                serverURLstring.removeLast()
            }
            
            return serverURLstring
        }
        
        return "https://\(serverURLstring).\(domains[0])"
    }
    
    static func getCurrentTimeInMicrosecond() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1_000_000)
    }
    
    static func parse(remoteNotification: [AnyHashable : Any], visitorId: String?) -> RoxchatRemoteNotification? {
        guard let remoteNotification = remoteNotification as? [String : Any?] else {
            return nil
        }
        if visitorId != nil {
            return RoxchatRemoteNotificationImpl(jsonDictionary: remoteNotification) as RoxchatRemoteNotification?
        } else {
            let notification = RoxchatRemoteNotificationImpl(jsonDictionary: remoteNotification) as RoxchatRemoteNotification?
            let params = notification?.getParameters()
            var indexOfId: Int
            switch notification?.getType() {
            case .operatorAccepted:
                indexOfId = 1
                break
            case .operatorFile,
                 .operatorMessage:
                indexOfId = 2
                break
            default:
                indexOfId = 0
            }
                    
            if params?.count ?? 0 <= indexOfId {
                return notification
            }
            return params?[indexOfId] == visitorId ? notification : nil
        }
    }
    
    static func isRoxchat(remoteNotification: [AnyHashable: Any]) -> Bool {
        if let roxchatField = remoteNotification[RoxchatRemoteNotificationImpl.APNSField.roxchat.rawValue] as? Bool {
            return roxchatField
        }
        
        return false
    }
    
}
