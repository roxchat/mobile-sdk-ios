//
//  UserDefaultsManager.swift
//  RoxchatClientLibrary_Example
//
//  Created by Anna Frolova on 22.11.2023.
//  Copyright © 2023 Roxchat. All rights reserved.
//

import Foundation
import RoxchatClientLibrary

protocol PropertyListValue: Codable {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Date: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}

struct Key: RawRepresentable {
    let rawValue: String
}

extension Key: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        rawValue = value
    }
}

enum UserDefaultsDomain: String {
    case shareModule = "group.roxchat.Share"
}

@propertyWrapper
struct UserDefault<T: PropertyListValue> {
    private let key: Key
    private var encode: Bool
    private let domain: String?
    private var storage: UserDefaults
    
    var wrappedValue: T? {
        get {
            let tmp = encode ? decodeAndGetValue() : (storage.object(forKey: key.rawValue) as? T)
            return tmp
        }
        set {
            encode ? encodeAndSetValue(newValue) : storage.set(newValue, forKey: key.rawValue)
        }
    }
    
    init(key: String, encode: Bool = false, domain: String? = nil) {
        self.key = Key(rawValue: key)
        self.domain = domain
        self.encode = encode
        storage = UserDefaults(suiteName: domain) ?? .standard
    }
    
    private func encodeAndSetValue(_ newValue: T?) {
        let encodedValue = try? PropertyListEncoder().encode(newValue)
        storage.set(encodedValue, forKey: key.rawValue)
    }
    
    private func decodeAndGetValue() -> T? {
        guard let data = storage.object(forKey: key.rawValue) as? Data else { return nil }
        return try? PropertyListDecoder().decode(T.self, from: data)
    }
}
