//
//  Parser.swift
//  RoxchatClientLibrary_Example
//
//  Created by Anna Frolova on 22.11.2023.
//  Copyright © 2023 Roxchat. All rights reserved.
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
