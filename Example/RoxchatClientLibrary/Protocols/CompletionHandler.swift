//
//  CompletionHandler.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import Foundation

protocol CompletionHandlerSettable {
    func set(completion: (any WMVisitorFieldsParserCompletionHandler)?)
}

protocol CompletionHandler: AnyObject {
    associatedtype OutputType
    associatedtype ErrorType: Error
    
    func onSuccess(value: OutputType)
    func onFailure(error: ErrorType)
}
