//
//  WMVisitorFieldsParser.swift
//  RoxchatClientLibrary_Example
//
//  Created by Anna Frolova on 22.11.2023.
//  Copyright © 2023 Roxchat. All rights reserved.
//

import RoxchatClientLibrary
import Foundation

typealias DemoVisitorOutput = (Data, DemoVisitor)
protocol WMVisitorFieldsParserCompletionHandler: CompletionHandler where OutputType == DemoVisitorOutput, ErrorType == WMVisitorFieldsError {}

class WMVisitorFieldsParser: Parser {
    typealias OutputValue = DemoVisitorOutput
    typealias InputValue = DemoVisitor
    typealias CompletionHandler = WMVisitorFieldsParserCompletionHandler
    
    var networkMangaer: NetworkManagerProtocol
    
    weak var completionHandler: (any WMVisitorFieldsParserCompletionHandler)?
    
    init(
        networkManager: NetworkManagerProtocol,
        completionHandler: (any WMVisitorFieldsParserCompletionHandler)?
    ) {
        self.networkMangaer = networkManager
        self.completionHandler = completionHandler
    }

    @available(iOS 13.0, *)
    func parse(value: DemoVisitor) async throws -> DemoVisitorOutput {
        guard let demoVisitor = try await networkMangaer.fetch(.demoVisitor(value.rawValue)) as? DemoVisitorOutput else {
            throw WMVisitorFieldsError.unknown
        }
        return demoVisitor
    }
    
    @available(*, deprecated, message: "Use parse(value:) async throws instead")
    func parse(value: DemoVisitor) {
        networkMangaer.fetch(.demoVisitor(value.rawValue))
    }
    
    func set(completion: (any WMVisitorFieldsParserCompletionHandler)?) {
        (networkMangaer as CompletionHandlerSettable).set(completion: completion)
    }
}

enum WMVisitorFieldsError: String, Error {
    case forbidden = "forbidden"
    case notFound = "roxchat_visitor not found"
    case unknown
}
