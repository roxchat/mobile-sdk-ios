
import Foundation
import UIKit

/**
 Class that handles HTTP-request sending by SDK.
 */
class AbstractRequestLoop {
    
    // MARK: - Constants
    enum HTTPMethods: String {
        case get = "GET"
        case post = "POST"
    }
    enum ResponseFields: String {
        case data = "data"
        case error = "error"
    }
    enum DataFields: String {
        case error = "error"
    }
    enum UnknownError: Error {
        case interrupted
        case serverError
    }
    
    // MARK: - Properties
    private let pauseCondition = NSCondition()
    private let pauseLock = NSRecursiveLock()
    var paused = true
    var running = true
    private var currentDataTask: URLSessionDataTask?
    let completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor?
    let internalErrorListener: InternalErrorListener?
    
    init(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor?,
         internalErrorListener: InternalErrorListener?) {
        self.completionHandlerExecutor = completionHandlerExecutor
        self.internalErrorListener = internalErrorListener
    }
    
    // MARK: - Methods
    
    func start() {
        preconditionFailure("This method must be overridden!")
    }
    
    func pause() {
        pauseLock.lock()
        paused = true
        pauseLock.unlock()
    }
    
    func resume() {
        pauseLock.lock()
        paused = false
        pauseCondition.broadcast()
        pauseLock.unlock()
    }
    
    func stop() {
        running = false
        resume()
            
        if let currentDataTask = currentDataTask {
            currentDataTask.cancel()
        }
    }
    
    func isRunning() -> Bool {
        return running
    }
    
    func perform(request: URLRequest) throws -> Data {
        var requestWithUserAgent = request
        requestWithUserAgent.setValue("iOS: Roxchat-Client 3.0.3; (\(UIDevice.current.model); \(UIDevice.current.systemVersion)); Bundle ID and version: \(Bundle.main.bundleIdentifier ?? "none") \(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "none")", forHTTPHeaderField: "User-Agent")
        
        var errorCounter = 0
        var lastHTTPCode = -1
        
        while isRunning() {
            let startTime = Date()
            var httpCode = 0
            
            let semaphore = DispatchSemaphore(value: 0)
            var receivedData: Data? = nil
            
            log(request: requestWithUserAgent)
            
            let dataTask = URLSession.shared.dataTask(with: requestWithUserAgent) { [weak self] data, response, error in
                guard let `self` = `self` else {
                    return
                }
                
                if let response = response,
                    let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    httpCode = statusCode
                }
                
                let roxchatLoggerEntry = self.configureLogMessage(
                    type: "response",
                    url: requestWithUserAgent.url,
                    parameters: requestWithUserAgent.httpBody,
                    code: httpCode,
                    data: data,
                    error: error
                )
                
                if let error = error {
                    semaphore.signal()
                    
                    RoxchatInternalLogger.shared.log(
                        entry: roxchatLoggerEntry,
                        logType: .networkRequest)
                    RoxchatInternalAlert.shared.present(title: .networkError, message: .noNetworkConnection)
                    
                    if let error = error as NSError?,
                        !(error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet) {
                        return
                    }
                }
                
                if let data = data {
                    receivedData = data
                    
                    RoxchatInternalLogger.shared.log(
                        entry: roxchatLoggerEntry,
                        verbosityLevel: .debug,
                        logType: .networkRequest)
                }
                
                semaphore.signal()
            }
            currentDataTask = dataTask
            dataTask.resume()
            
            _ = semaphore.wait(timeout: .distantFuture)
            currentDataTask = nil
            blockUntilPaused()
            
            if !isRunning() {
                break
            }
            
            if httpCode == 0 {
                if let handler = self.completionHandlerExecutor {
                    handler.execute(task: DispatchWorkItem {
                        self.internalErrorListener?.onNotFatal(error: .noNetworkConnection)
                        self.internalErrorListener?.connectionStateChanged(connected: false)
                    })
                    usleep(useconds_t(10_000_000.0))
                } else {
                    throw UnknownError.serverError
                }
                continue
            }
            
            if let receivedData = receivedData,
               (httpCode == 200 || httpCode == 400 || httpCode == 403 || httpCode == 413 || httpCode == 415) {
                self.internalErrorListener?.connectionStateChanged(connected: true)
                return receivedData
            }
            
            if httpCode == lastHTTPCode {
                let roxchatLoggerEntry = self.configureLogMessage(
                    type: "Request failed",
                    url: requestWithUserAgent.url,
                    parameters: requestWithUserAgent.httpBody,
                    code: httpCode
                )
                RoxchatInternalLogger.shared.log(
                    entry: roxchatLoggerEntry,
                    verbosityLevel: .warning,
                    logType: .networkRequest)
            }
            
            errorCounter += 1
            
            lastHTTPCode = httpCode
            
            // If request wasn't successful and error isn't fatal, wait some time and try again.
            if (errorCounter > 4) {
                // If there was more that five tries stop trying.
                self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                    self.internalErrorListener?.onNotFatal(error: .serverIsNotAvailable)
                })
                throw UnknownError.serverError
            }
            let sleepTime = Double(errorCounter) as TimeInterval
            let timeElapsed = Date().timeIntervalSince(startTime)
            if Double(timeElapsed) < Double(sleepTime) {
                let remainingTime = Double(sleepTime) - Double(timeElapsed)
                usleep(useconds_t(remainingTime * 1_000_000.0))
            }
        }
        
        throw UnknownError.interrupted
    }
    
    func handleRequestLoop(error: UnknownError) {
        switch error {
        case .interrupted:
            RoxchatInternalLogger.shared.log(
                entry: "Request interrupted (it's OK if RoxchatSession object was destroyed).",
                verbosityLevel: .debug,
                logType: .networkRequest)
            
            break
        case .serverError:
            RoxchatInternalLogger.shared.log(
                entry: "Request failed with server error.",
                logType: .networkRequest)
            
            break
        }
    }

    func decodeToServerSideSettings(data: Data) throws -> RoxchatServerSideSettings  {
        let readyData = prepareServerSideData(rawData: data)
        let roxchatServerSideSettings = try JSONDecoder().decode(RoxchatServerSideSettings.self, from: readyData)
        return roxchatServerSideSettings
    }

    func prepareServerSideData(rawData: Data) -> Data {
        guard var rawDataString = String(data: rawData, encoding: .utf8),
              rawDataString.count >= 33 else {
            return Data()
        }

        rawDataString.removeFirst(31)
        rawDataString.removeLast(2)

        guard let newData = rawDataString.data(using: .utf8, allowLossyConversion: false) else {
            return Data()
        }
        return newData
    }
    
    // MARK: Private methods
    
    private func blockUntilPaused() {
        pauseCondition.lock()
        while paused {
            pauseCondition.wait()
        }
        pauseCondition.unlock()
    }
    
    private func log(request: URLRequest) {
        let roxchatLoggerEntry = configureLogMessage(type: "request",
                                                   method: request.httpMethod,
                                                   url: request.url,
                                                   parameters: request.httpBody)
        
        RoxchatInternalLogger.shared.log(
            entry: roxchatLoggerEntry,
            verbosityLevel: .info,
            logType: .networkRequest)
    }
    
    static var logRequestData = true
    
    private func configureLogMessage(type: String,
                                     method: String? = nil,
                                     url: URL? = nil,
                                     parameters: Data? = nil,
                                     code: Int? = nil,
                                     data: Data? = nil,
                                     error: Error? = nil) -> String {
        if !AbstractRequestLoop.logRequestData {
            return ""
        }
        var logMessage = "Roxchat \(type):"
        
        if let method = method {
            logMessage += ("\nHTTP method - \(method)")
        }
        
        if let url = url {
            logMessage += "\nURL – \(url.absoluteString)"
        }
        
        if let parameters = parameters {
            if let parametersString = String(data: parameters,
                                             encoding: .utf8) {
                logMessage += "\nParameters – \(parametersString)"
            }
        }
        
        if let code = code {
            logMessage += "\nHTTP code – \(code)"
        }
        
        if let data = data {
            logMessage += self.encode(responseData: data)
        }
        
        if let error = error {
            logMessage += "\nError – \(error.localizedDescription)"
        }
        
        return logMessage
    }
    
    private func encode(responseData: Data) -> String {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: responseData,
                                                                options: .mutableContainers)
            let prettyPrintedJSONResponse = try JSONSerialization.data(withJSONObject: jsonResponse,
                                                                       options: .prettyPrinted)
            
            if let dataResponseString = String(data: prettyPrintedJSONResponse,
                                               encoding: .utf8) {
                return "\nJSON:\n" + dataResponseString
            }
        } catch {
            if let dataResponseString = String(data: responseData,
                                               encoding: .utf8) {
                return "\nData:\n" + dataResponseString
            }
        }
        
        return ""
    }
    
}
