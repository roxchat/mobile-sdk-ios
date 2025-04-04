//
//  WMSessionController.swift
//  RoxchatClientLibrary
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import Foundation

// MARK: - Constants
fileprivate enum WMKeychainWrapperName: String {
    case main = "ru.roxchat.RoxchatClientSDKiOS.visitor."
}
fileprivate enum WMKeychainWrapperMainPrefix: String {
    case sessionID = "session_id"
}

class WMSessionController {
    
    static var shared: WMSessionController = WMSessionController()
    
    private var sessions: [WeakRefference<RoxchatSessionImpl>] = []
    
    func add(session: RoxchatSessionImpl) {
        sessions.append(WeakRefference(session))
    }
    
    func remove(session: RoxchatSessionImpl) {
        sessions.removeAll { $0.value === session }
    }
    
    func session(visitorName: String, accountName: String, location: String, mobileChatInstance: String) -> RoxchatSessionImpl? {
        let userDefaultsKey = WMKeychainWrapperName.main.rawValue + visitorName + "." + mobileChatInstance
        let userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey)
        
        guard let sessionID = userDefaults?[WMKeychainWrapperMainPrefix.sessionID.rawValue] as? String else {
            return nil
        }
        
        if let _ = sessions.filter({ $0.value?.getSessionID() == sessionID }).first?.value {
            RoxchatInternalLogger.shared.log(entry: "New session initialization prevented. Current session already exist")
        } else {
            RoxchatInternalLogger.shared.log(entry: "Session dosen't exist. New session initialization required")
        }
        
        return sessions
            .filter { $0.value?.getSessionID() == sessionID }
            .first?
            .value
    }
}

