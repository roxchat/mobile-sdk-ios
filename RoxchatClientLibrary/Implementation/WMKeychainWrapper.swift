
import UIKit
import Security
import Foundation

public class WMKeychainWrapper: NSObject {

    public static let dbFilePrefix = "roxchat_"
    public static let fileGuidURLDictionaryKey = "fileGuidURLDictionaryKey"
    public static let deviceTokenKey = "device-token"
    public static let roxchatKeyPrefix = "ru.roxchat."
    let roxchatUserDefaultsFirstRunKey = "ru.roxchat.userDefaultsFirstRunKey"
    public static var keychainAccessGroupName = ""
    public var userDefaults = UserDefaults.standard
    private var inited = false
    
    override init() {
        super.init()
        cleanUserDefaults()
    }
    
    public func setAppGroupName(userDefaults: UserDefaults, keychainAccessGroup: String) {
        WMKeychainWrapper.keychainAccessGroupName = keychainAccessGroup
        self.userDefaults = userDefaults
    }
    
    private func cleanUserDefaults() {
        if inited {
            return
        }
        inited = true
        
        userDefaults.removeObject(forKey: "fileGuidURLDictionaryKey")
        userDefaults.removeObject(forKey: "ru.roxchat.RoxchatClientSDKiOS.guid")
        userDefaults.removeObject(forKey: "settings")
        userDefaults.removeObject(forKey: "previous_account")
        userDefaults.removeObject(forKey: "device-token")
        for key in userDefaults.dictionaryRepresentation().keys {
            if key.starts(with: "ru.roxchat.RoxchatClientSDKiOS") {
                userDefaults.removeObject(forKey: key)
            }
        }
        
        if !userDefaults.bool(forKey: roxchatUserDefaultsFirstRunKey) {
            userDefaults.set(true, forKey: roxchatUserDefaultsFirstRunKey)
            
            for key in getAllKeychainItems() {
                if let key = key {
                    if key.starts(with: WMKeychainWrapper.roxchatKeyPrefix) {
                        if !key.contains(WMKeychainWrapper.deviceTokenKey) {
                            _ = WMKeychainWrapper.removeObject(key: key)
                        }
                    }
                }
            }
        }
        
        // remove old db files
        for file in FileManager.default.urls(for: .libraryDirectory) ?? [] {
            if fileIsRoxchatDb(url: file) {
                if !DBFileIsActual(url: file) {
                    do {
                        print("delete old db file: \(file)")
                        try FileManager.default.removeItem(at: file)
                    } catch {
                        print("Could not delete old db file: \(error) \(file)")
                    }
                }
            }
        }
    }
    
    static func actualDBPrefix() -> String {
        return WMKeychainWrapper.dbFilePrefix + "\(SQLiteHistoryStorage.getMajorVersion())_"
    }
    
    func fileIsRoxchatDb(url: URL) -> Bool {
        let fileName = url.lastPathComponent
        return  fileName.hasPrefix(WMKeychainWrapper.dbFilePrefix) && fileName.hasSuffix(".db")
    }
    
    func DBFileIsActual(url: URL) -> Bool {
        let fileName = url.lastPathComponent
        return fileName.hasPrefix(WMKeychainWrapper.actualDBPrefix())
    }
    
    public static var standard: WMKeychainWrapper = WMKeychainWrapper()
    
    open func dictionary(forKey defaultName: String) -> [String : Any]? {
        return WMKeychainWrapper.load(key: defaultName)?.dataToDictionary()
    }
    open func setDictionary(_ value: [String : Any]?, forKey defaultName: String) {
        _ = WMKeychainWrapper.save(key: defaultName, data: Data.dataFromDictionary(value))
    }
    
    public func setString(_ value: String, forKey key: String) {
        WMKeychainWrapper.saveString(key: key, value: value)
    }
    
    open func string(forKey defaultName: String) -> String? {
        return WMKeychainWrapper.readString(key: defaultName)
    }

    static func removeObject(key: String) -> OSStatus{
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrAccessGroup as String: keychainAccessGroupName as AnyObject]
        return SecItemDelete(query as CFDictionary)
    }
    
    class func saveString(key: String, value: String) {
        let data = Data(value.utf8)
        _ = WMKeychainWrapper.save(key: key, data: data)
    }
    
    class func readString(key: String) -> String? {
        
        if let receivedData = WMKeychainWrapper.load(key: key) {
            return String(decoding: receivedData, as: UTF8.self)
        }
        return nil
    }
    
    class func save(key: String, data: Data?) -> OSStatus {
        let secureStringKey = roxchatKeyPrefix + key
        
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : secureStringKey,
            kSecValueData as String   : data as Any,
            kSecAttrAccessGroup as String: keychainAccessGroupName as AnyObject] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        
        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: String) -> Data? {
        let secureStringKey = roxchatKeyPrefix + key
        
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : secureStringKey,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne,
            kSecAttrAccessGroup as String: keychainAccessGroupName as AnyObject] as [String : Any]
        
        var dataTypeRef: AnyObject? = nil
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    open func getAllKeychainItems() -> [String?] {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecMatchLimit as String: kSecMatchLimitAll,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnRef as String: true,
                                    kSecAttrAccessGroup as String: WMKeychainWrapper.keychainAccessGroupName as AnyObject]
        var items_ref: CFTypeRef?
        _ = SecItemCopyMatching(query as CFDictionary, &items_ref)
        let items = items_ref as? Array<Dictionary<String, Any>> ?? []
        
        return items.map({$0[kSecAttrAccount as String] as? String})
    }
}

extension Data {

    static func dataFromDictionary(_ dict: [String: Any]?) -> Data? {
        if dict == nil {
            return nil
        }
        var data: Data? = nil
        do {
            data = try PropertyListSerialization.data(fromPropertyList: dict as Any, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
        } catch {
            print(error)
        }
        return data
    }
    
    func dataToDictionary() -> [String: Any]? {
        
        var dict: [String: Any]?
        do {
            let dicFromData = try PropertyListSerialization.propertyList(from: self, options: PropertyListSerialization.ReadOptions.mutableContainers, format: nil)
            dict = dicFromData as? [String: Any]
        } catch{
            print(error)
        }
        return dict
    }
}

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
