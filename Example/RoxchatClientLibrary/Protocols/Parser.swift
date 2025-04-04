//
//  Parser.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import Foundation

protocol Parser {
    associatedtype OutputValue
    associatedtype InputValue
    associatedtype CompletionHandler
    
    var completionHandler: CompletionHandler? { get set }
    var networkMangaer: NetworkManagerProtocol { get set }
    
    func parse(value: InputValue)
    
    @available(iOS 13.0, *)
    func parse(value: InputValue) async throws -> OutputValue
}
