
import Foundation

/**
 Class that handles HTTP-requests sended by RoxchatClientLibrary with visitor FAQ actions.
 */
class FAQRequestLoop: AbstractRequestLoop {
    
    // MARK: - Properties
    private let completionFAQHandlerExecutor: ExecIfNotDestroyedFAQHandlerExecutor
    var operationQueue: OperationQueue?
    
    // MARK: - Initialization
    init(completionHandlerExecutor: ExecIfNotDestroyedFAQHandlerExecutor,
         baseURL: String) {
        self.completionFAQHandlerExecutor = completionHandlerExecutor
        super.init(completionHandlerExecutor: nil,
                   internalErrorListener: nil,
                   requestHeader: nil,
                   baseURL: baseURL)
    }
    
    // MARK: - Methods
    
    override func start() {
        guard operationQueue == nil else {
            return
        }
        
        operationQueue = OperationQueue()
        operationQueue?.maxConcurrentOperationCount = 1
        operationQueue?.qualityOfService = .userInitiated
    }
    
    override func stop() {
        super.stop()
        
        operationQueue?.cancelAllOperations()
        operationQueue = nil
    }
    
    func enqueue(request: RoxchatRequest) {
        operationQueue?.addOperation { [weak self] in
            guard let `self` = self else {
                return
            }
            
            if !self.isRunning() {
                return
            }
            
            let parameterDictionary = request.getPrimaryData()
            let parametersString = parameterDictionary.stringFromHTTPParameters()
            
            var urlRequest: URLRequest?
            let httpMethod = request.getHTTPMethod()
            if httpMethod == .get {
                guard let url = URL(string: (request.getBaseURLString() + "?" + parametersString)) else {
                    RoxchatInternalLogger.shared.log(
                        entry: "Invalid URL in FAQRequestLoop.\(#function)",
                        logType: .networkRequest)
                    return
                }
                urlRequest = URLRequest(url: url)
            } else { // POST
                
                // For URL encoded requests.
                guard let url = URL(string: request.getBaseURLString()) else {
                    RoxchatInternalLogger.shared.log(
                        entry: "Invalid URL in FAQRequestLoop.\(#function)",
                        logType: .networkRequest)
                    return
                }
                urlRequest = URLRequest(url: url)
                urlRequest?.httpBody = parametersString.data(using: .utf8)
                
                
                // Assuming that content type field is always exists when it is POST request, and does not when request is of GET type.
                urlRequest?.setValue(request.getContentType(),
                                     forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest?.httpMethod = httpMethod.rawValue
            
            do {
                guard let urlRequest = urlRequest else {
                    RoxchatInternalLogger.shared.log(
                        entry: "URL Request is nil in FAQRequestLoop.\(#function)",
                        logType: .networkRequest)
                    return
                }
                let data = try self.perform(request: urlRequest)
                var wasCompletionHandler = false
                if let _ = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    if let completionHandler = request.getFAQCompletionHandler() {
                        self.completionFAQHandlerExecutor.execute(task: DispatchWorkItem {
                            do {
                                try completionHandler(data)
                                wasCompletionHandler = true
                            } catch {
                            }
                            self.handleClientCompletionHandlerOf(request: request)
                        })
                    }
                }
                if let _ = try? JSONSerialization.jsonObject(with: data) as? [Int] {
                    if let completionHandler = request.getFAQCompletionHandler() {
                        self.completionFAQHandlerExecutor.execute(task: DispatchWorkItem {
                            do {
                                try completionHandler(data)
                                wasCompletionHandler = true
                            } catch {
                            }
                            self.handleClientCompletionHandlerOf(request: request)
                        })
                    }
                }
                if let dataJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if (dataJSON[AbstractRequestLoop.ResponseFields.error.rawValue] as? String) != nil {
                        self.running = false

                        return
                    }
                    
                    if let completionHandler = request.getFAQCompletionHandler() {
                        self.completionFAQHandlerExecutor.execute(task: DispatchWorkItem {
                            do {
                                try completionHandler(data)
                                wasCompletionHandler = true
                            } catch {
                            }
                            self.handleClientCompletionHandlerOf(request: request)
                        })
                    }
                    
                }
                if !wasCompletionHandler {
                    if let completionHandler = request.getFAQCompletionHandler() {
                        self.completionFAQHandlerExecutor.execute(task: DispatchWorkItem {
                            do {
                                try completionHandler(data)
                            } catch {
                            }
                            self.handleClientCompletionHandlerOf(request: request)
                        })
                    }
                }
            } catch let unknownError as UnknownError {
                if let completionHandler = request.getFAQCompletionHandler() {
                    self.completionFAQHandlerExecutor.execute(task: DispatchWorkItem {
                        do {
                            try completionHandler(nil)
                        } catch {
                        }
                        self.handleClientCompletionHandlerOf(request: request)
                    })
                }
                self.handleRequestLoop(error: unknownError)
            } catch {
                if let completionHandler = request.getFAQCompletionHandler() {
                    self.completionFAQHandlerExecutor.execute(task: DispatchWorkItem {
                        do {
                            try completionHandler(nil)
                        } catch {
                        }
                        self.handleClientCompletionHandlerOf(request: request)
                    })
                }
            }
        }
    }
    
    // MARK: Private methode
    
    private func handleClientCompletionHandlerOf(request: RoxchatRequest) {
        completionFAQHandlerExecutor.execute(task: DispatchWorkItem {
            
            guard let messageID = request.getMessageID() else {
                RoxchatInternalLogger.shared.log(
                    entry: "Request has not message ID in FAQRequestLoop.\(#function)",
                    logType: .networkRequest)
                return
            }
            
            request.getDataMessageCompletionHandler()?.onSuccess(messageID: messageID)
            request.getSendFileCompletionHandler()?.onSuccess(messageID: messageID)
            request.getRateOperatorCompletionHandler()?.onSuccess()
            request.getDeleteMessageCompletionHandler()?.onSuccess(messageID: messageID)
            request.getEditMessageCompletionHandler()?.onSuccess(messageID: messageID)
        })
    }
    
}
