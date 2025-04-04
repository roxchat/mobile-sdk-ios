
import Foundation

/**
 */
final class RoxchatClientBuilder {
    
    // MARK: - Properties
    private var appVersion: String?
    private var prechat: String?
    private var authorizationData: AuthorizationData?
    private var baseURL: String?
    private var completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor?
    private var deltaCallback: DeltaCallback?
    private var deviceID: String?
    private var deviceToken: String?
    private var remoteNotificationSystem: Roxchat.RemoteNotificationSystem?
    private var internalErrorListener: InternalErrorListener?
    private var notFatalErrorHandler: NotFatalErrorHandler?
    private var location: String?
    private var providedAuthenticationToken: String?
    private weak var providedAuthenticationTokenStateListener: ProvidedAuthorizationTokenStateListener?
    private var requestHeader: [String: String]?
    private var sessionID: String?
    private var sessionParametersListener: SessionParametersListener?
    private var title: String?
    private var visitorFieldsJSONString: String?
    private var visitorJSONString: String?
    
    // MARK: - Builder methods
    
    func set(appVersion: String?) -> RoxchatClientBuilder {
        self.appVersion = appVersion
        
        return self
    }
    
    func set(baseURL: String) -> RoxchatClientBuilder {
        self.baseURL = baseURL
        
        return self
    }
    
    func set(location: String) -> RoxchatClientBuilder {
        self.location = location
        
        return self
    }
    
    func set(deltaCallback: DeltaCallback) -> RoxchatClientBuilder {
        self.deltaCallback = deltaCallback
        
        return self
    }
    
    func set(sessionParametersListener: SessionParametersListener) -> RoxchatClientBuilder {
        self.sessionParametersListener = sessionParametersListener
        
        return self
    }
    
    func set(internalErrorListener: InternalErrorListener) -> RoxchatClientBuilder {
        self.internalErrorListener = internalErrorListener
        
        return self
    }
    
    func set(visitorJSONString: String?) -> RoxchatClientBuilder {
        self.visitorJSONString = visitorJSONString
        
        return self
    }
    
    func set(visitorFieldsJSONString: String?) -> RoxchatClientBuilder {
        self.visitorFieldsJSONString = visitorFieldsJSONString
        
        return self
    }
    
    func set(providedAuthenticationTokenStateListener: ProvidedAuthorizationTokenStateListener?,
             providedAuthenticationToken: String? = nil) -> RoxchatClientBuilder {
        self.providedAuthenticationTokenStateListener = providedAuthenticationTokenStateListener
        self.providedAuthenticationToken = providedAuthenticationToken
        
        return self
    }
    
    func set(requestHeader: [String: String]?) -> RoxchatClientBuilder {
        self.requestHeader = requestHeader
        
        return self
    }
    
    func set(sessionID: String?) -> RoxchatClientBuilder {
        self.sessionID = sessionID
        
        return self
    }
    
    func set(authorizationData: AuthorizationData?) -> RoxchatClientBuilder {
        self.authorizationData = authorizationData
        
        return self
    }
    
    func set(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor?) -> RoxchatClientBuilder {
        self.completionHandlerExecutor = completionHandlerExecutor
        
        return self
    }
    
    func set(title: String) -> RoxchatClientBuilder {
        self.title = title
        
        return self
    }
    
    func set(deviceToken: String?) -> RoxchatClientBuilder {
        self.deviceToken = deviceToken
        
        return self
    }
    
    func set(remoteNotificationSystem: Roxchat.RemoteNotificationSystem?) -> RoxchatClientBuilder {
        self.remoteNotificationSystem = remoteNotificationSystem
        
        return self
    }
    
    func set(deviceID: String?) -> RoxchatClientBuilder {
        self.deviceID = deviceID
        
        return self
    }
    
    func set(notFatalErrorHandler: NotFatalErrorHandler?) -> RoxchatClientBuilder {
        self.notFatalErrorHandler = notFatalErrorHandler
        
        return self
    }
    
    func set(prechat:String?) -> RoxchatClientBuilder {
        self.prechat = prechat
        return self
    }
    
    func build() -> RoxchatClient {
        guard let completionHandlerExecutor = completionHandlerExecutor else {
            RoxchatInternalLogger.shared.log(entry: "Building Roxchat client failure because Completion Handler Executor is nil in RoxchatClient.\(#function)")
            fatalError("Building Roxchat client failure because Completion Handler Executor is nil in RoxchatClient.\(#function)")
        }
        guard let internalErrorListener = internalErrorListener else {
            RoxchatInternalLogger.shared.log(entry: "Building Roxchat client failure because Internal Error Listener is nil in RoxchatClient.\(#function)")
            fatalError("Building Roxchat client failure because Internal Error Listener is nil in RoxchatClient.\(#function)")
        }
        
        guard let baseURL = baseURL else {
            RoxchatInternalLogger.shared.log(entry: "Building Roxchat client failure because Base URL is nil in RoxchatClient.\(#function)")
            fatalError("Building Roxchat client failure because Base URL is nil in RoxchatClient.\(#function)")
        }
        
        let actionRequestLoop = ActionRequestLoop(completionHandlerExecutor: completionHandlerExecutor,
                                                  internalErrorListener: internalErrorListener,
                                                  notFatalErrorHandler: notFatalErrorHandler,
                                                  requestHeader: requestHeader,
                                                  baseURL: baseURL)
        
        actionRequestLoop.set(authorizationData: authorizationData)
        
        guard let deltaCallback = deltaCallback else {
            RoxchatInternalLogger.shared.log(entry: "Building Roxchat client failure because Delta Callback is nil in RoxchatClient.\(#function)")
            fatalError("Building Roxchat client failure because Delta Callback is nil in RoxchatClient.\(#function)")
        }
        guard let title = title else {
            RoxchatInternalLogger.shared.log(entry: "Building Roxchat client failure because Title is nil in RoxchatClient.\(#function)")
            fatalError("Building Roxchat client failure because Title is nil in RoxchatClient.\(#function)")
        }
        guard let location = location else {
            RoxchatInternalLogger.shared.log(entry: "Building Roxchat client failure because Location is nil in RoxchatClient.\(#function)")
            fatalError("Building Roxchat client failure because Location is nil in RoxchatClient.\(#function)")
        }
        guard let deviceID = deviceID else {
            RoxchatInternalLogger.shared.log(entry: "Building Roxchat client failure because Device ID is nil in RoxchatClient.\(#function)")
            fatalError("Building Roxchat client failure because Device ID is nil in RoxchatClient.\(#function)")
        }
        
        let deltaRequestLoop = DeltaRequestLoop(deltaCallback: deltaCallback,
                                                completionHandlerExecutor: completionHandlerExecutor,
                                                sessionParametersListener: SessionParametersListenerWrapper(withSessionParametersListenerToWrap: sessionParametersListener,
                                                                                                            actionRequestLoop: actionRequestLoop),
                                                internalErrorListener: internalErrorListener,
                                                baseURL: baseURL,
                                                title: title,
                                                location: location,
                                                appVersion: appVersion,
                                                visitorFieldsJSONString: visitorFieldsJSONString,
                                                providedAuthenticationTokenStateListener: providedAuthenticationTokenStateListener,
                                                providedAuthenticationToken: providedAuthenticationToken,
                                                deviceID: deviceID,
                                                deviceToken: deviceToken,
                                                remoteNotificationSystem: remoteNotificationSystem,
                                                visitorJSONString: visitorJSONString,
                                                sessionID: sessionID,
                                                prechat: prechat,
                                                authorizationData: authorizationData,
                                                requestHeader: requestHeader)
        
        return RoxchatClient(withActionRequestLoop: actionRequestLoop,
                             deltaRequestLoop: deltaRequestLoop,
                             roxchatActions: RoxchatActionsImpl(actionRequestLoop: actionRequestLoop))
    }
    
}

/**
 Class that is responsible for history storage when it is set to memory mode.
 */
final class RoxchatClient {
    
    // MARK: - Properties
    private let actionRequestLoop: ActionRequestLoop
    private let deltaRequestLoop: DeltaRequestLoop
    private let roxchatActions: RoxchatActionsImpl
    
    // MARK: - Initialization
    init(withActionRequestLoop actionRequestLoop: ActionRequestLoop,
         deltaRequestLoop: DeltaRequestLoop,
         roxchatActions: RoxchatActionsImpl) {
        self.actionRequestLoop = actionRequestLoop
        self.deltaRequestLoop = deltaRequestLoop
        self.roxchatActions = roxchatActions
    }
    
    // MARK: - Methods
    
    func start() {
        deltaRequestLoop.start()
        actionRequestLoop.start()
    }
    
    func pause() {
        deltaRequestLoop.pause()
        actionRequestLoop.pause()
    }
    
    func resume() {
        deltaRequestLoop.resume()
        actionRequestLoop.resume()
    }
    
    func stop() {
        deltaRequestLoop.stop()
        actionRequestLoop.stop()
    }
    
    func set(deviceToken: String) {
        deltaRequestLoop.set(deviceToken: deviceToken)
        roxchatActions.update(deviceToken: deviceToken)
    }
    
    func getDeltaRequestLoop() -> DeltaRequestLoop {
        return deltaRequestLoop
    }
    
    func getActions() -> RoxchatActionsImpl {
        return roxchatActions
    }
    
    func setRequestHeader(key: String, value: String) {
        deltaRequestLoop.setRequestHeader(key: key, value: value)
        actionRequestLoop.setRequestHeader(key: key, value: value)
    }
}

/**
 */
final private class SessionParametersListenerWrapper: SessionParametersListener {
    
    // MARK: - Properties
    private let wrappedSessionParametersListener: SessionParametersListener?
    private let actionRequestLoop: ActionRequestLoop
    
    // MARK: - Initializers
    init(withSessionParametersListenerToWrap wrappingSessionParametersListener: SessionParametersListener?,
         actionRequestLoop: ActionRequestLoop) {
        wrappedSessionParametersListener = wrappingSessionParametersListener
        self.actionRequestLoop = actionRequestLoop
    }
    
    // MARK: - SessionParametersListener protocol methods
    func onSessionParametersChanged(visitorFieldsJSONString visitorJSONString: String,
                                    sessionID: String,
                                    authorizationData: AuthorizationData) {
        actionRequestLoop.set(authorizationData: authorizationData)
        
        wrappedSessionParametersListener?.onSessionParametersChanged(visitorFieldsJSONString: visitorJSONString,
                                                                     sessionID: sessionID,
                                                                     authorizationData: authorizationData)
    }
    
}
