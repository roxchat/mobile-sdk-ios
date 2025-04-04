//
//  NetworkUtils.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//


import Foundation

struct InternalScheme: RawRepresentable {
    static let https = InternalScheme(rawValue: "https")
    let rawValue: String
}

struct InternalHost {
    static let defaultHost = "demo.rox.chat"
    static var currentHost: String {
        let host = Settings.shared.accountName
        if host.contains("https://") {
            return host.replacingOccurrences(of: "https://", with: "")
        } else {
            return Settings.shared.accountName + ".rox.chat"
        }
    }
}

enum InternalPath: String {
    case demoVisitor = "/l/v/m/demo-visitor"
}

enum InternalQueryKeys: String {
    case demoVisitor = "roxchat-visitor"
}

enum InternalURLKind {
    case demoVisitor(Int)
}

extension URLRequest {
    init(components: URLComponents) {
        guard let url = components.url else {
            preconditionFailure()
        }
        self.init(url: url)
    }
}

extension Data {
    
    var toVisitorFieldsError: WMVisitorFieldsError? {
        let dictionary = try? JSONSerialization.jsonObject(with: self) as? [String: String]
        
        return dictionary?
            .filter { $0.key == "error" }
            .first
            .flatMap {
                switch $0.value {
                case WMVisitorFieldsError.notFound.rawValue:
                    return WMVisitorFieldsError.notFound
                case WMVisitorFieldsError.forbidden.rawValue:
                    return .forbidden
                default:
                    return .unknown
                }
            }
    }
}

extension URLComponents {
    init(
        scheme: InternalScheme = .https,
        host: String = InternalHost.defaultHost,
        path: String,
        queryItems: [URLQueryItem]? = nil
    ) {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.path = path
        components.queryItems = queryItems
        self = components
    }
}

extension URLComponents {
    
    static func components(for kind: InternalURLKind) -> URLComponents {
        switch kind {
        case .demoVisitor(let value):
            return componentsForDemoVisitor(demoVisitor: value)
        }
    }
    
    private static func componentsForDemoVisitor(demoVisitor: Int) -> URLComponents {
        URLComponents(
            scheme: .https,
            host: InternalHost.currentHost,
            path: InternalPath.demoVisitor.rawValue,
            queryItems: [
                URLQueryItem(name: InternalQueryKeys.demoVisitor.rawValue, value: String(demoVisitor))
            ]
        )
    }
}
