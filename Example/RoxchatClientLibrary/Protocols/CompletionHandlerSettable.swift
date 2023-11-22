//
//  CompletionHandlerSettable.swift
//  RoxchatClientLibrary_Example
//
//  Created by Anna Frolova on 22.11.2023.
//  Copyright © 2023 Roxchat. All rights reserved.
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
