//
//  WMVisitorFieldsParser.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import Foundation
import RoxchatClientLibrary

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
