//
//  NetworkManager.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import Foundation

enum RequestKind {
    case demoVisitor(Int)
}

protocol NetworkManagerProtocol: CompletionHandlerSettable {
    init(urlSession: URLSession)
    
    func fetch(_ requestKind: RequestKind)
    
    @available(iOS 13.0, *)
    func fetch(_ requestKind: RequestKind) async throws -> Any
}

class NetworkManager: NetworkManagerProtocol {
    private var urlSession: URLSession
    private weak var demoVisitorCompletion: (any WMVisitorFieldsParserCompletionHandler)?
    
    required init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetch(_ requestKind: RequestKind) {
        var urlComponents: URLComponents
        switch requestKind {
        case .demoVisitor(let value):
            urlComponents = .components(for: .demoVisitor(value))
        }
        
        let request = URLRequest(components: urlComponents)
        
        switch requestKind {
        case .demoVisitor(let value):
            demoVisitorRequest(request: request, value: value)
        }
    }
    
    @available(iOS 13.0, *)
    func fetch(_ requestKind: RequestKind) async throws -> Any {
        var urlComponents: URLComponents
        switch requestKind {
        case .demoVisitor(let value):
            urlComponents = .components(for: .demoVisitor(value))
        }
        
        let request = URLRequest(components: urlComponents)
        
        switch requestKind {
        case .demoVisitor(let value):
            return try await demoVisitorAsyncRequest(request: request, value: value)
        }
    }
    
    private func demoVisitorRequest(request: URLRequest, value: Int) {
        urlSession.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            if error != nil {
                self.demoVisitorCompletion?.onFailure(error: .unknown)
                return
            }
            
            guard let data = data else {
                self.demoVisitorCompletion?.onFailure(error: .unknown)
                return
            }
            
            if let visitorFieldsError = data.toVisitorFieldsError {
                self.demoVisitorCompletion?.onFailure(error: visitorFieldsError)
            } else {
                self.demoVisitorCompletion?.onSuccess(value: DemoVisitorOutput(data, DemoVisitor(rawValue: value)))
            }
            
        }.resume()
    }
    
    @available(iOS 13.0, *)
    private func demoVisitorAsyncRequest(request: URLRequest, value: Int) async throws -> Any {
        return try await withCheckedThrowingContinuation { continuation in
            urlSession.dataTask(with: request) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data = data else {
                    continuation.resume(throwing: WMVisitorFieldsError.notFound)
                    return
                }
                
                if let visitorFieldsError = data.toVisitorFieldsError {
                    continuation.resume(throwing: visitorFieldsError)
                } else {
                    continuation.resume(returning: DemoVisitorOutput(data, DemoVisitor(rawValue: value)))
                }
                
            }.resume()
        }
    }
}

// MARK: - Conform to CompletionHandlerSettable

extension NetworkManager: CompletionHandlerSettable {
    func set(completion: (any WMVisitorFieldsParserCompletionHandler)?) {
        self.demoVisitorCompletion = completion
    }
}
