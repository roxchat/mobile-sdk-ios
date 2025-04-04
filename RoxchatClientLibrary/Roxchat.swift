
import Foundation

/**
 Main point of RoxchatClientLibrary.
 */
public final class Roxchat {

    /**
     Returns new SessionBuilder object for creating RoxchatSession object.
     - returns:
     The instance of RoxchatSession builder.
     */
    static public func newSessionBuilder() -> SessionBuilder {
        return SessionBuilder()
    }
    
    /**
     Returns new FAQBuilder object for creating FAQ object.
     - returns:
     The instance of FAQ builder.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    static public func newFAQBuilder() -> FAQBuilder {
        return FAQBuilder()
    }

    /**
     Deserializes received remote notification.
     This method can be called with `userInfo` parameter of your UIApplicationDelegate method `application(_:didReceiveRemoteNotification:)`.
     Remote notification dictionary must be stored inside standard APNs key "aps".
     - parameter remoteNotification:
     User info of received remote notification.
     - returns:
     Remote notification object or nil if there's no useful payload or this notification is sent not by Roxchat service.
     - seealso:
     `SessionBuilder.set(remoteNotificationsSystem:)`
     `isRoxchat(remoteNotification:)`
     */
    static public func parse(remoteNotification: [AnyHashable : Any], visitorId: String? = nil) -> RoxchatRemoteNotification? {
        return InternalUtils.parse(remoteNotification: remoteNotification, visitorId: visitorId)
    }

    /**
     If remote notifications (SessionBuilder.setRemoteNotificationSystem) are enabled for the session, then you can receive remote notifications belonging to this session.
     This method can be called with `userInfo` parameter of your UIApplicationDelegate method `application(_:didReceiveRemoteNotification:)`.
     Remote notification dictionary must be stored inside standard APNs key "aps".
     - parameter remoteNotification:
     User info of received remote notification.
     - returns:
     Boolean value that indicates is received remote notification is sent by Roxchat service.
     - seealso:
     `SessionBuilder.set(remoteNotificationSystem:)`
     `parseRemoteNotification()`
     */
    static public func isRoxchat(remoteNotification: [AnyHashable: Any]) -> Bool {
        return InternalUtils.isRoxchat(remoteNotification: remoteNotification)
    }


    // MARK: -
    /**
     - seealso:
     `SessionBuilder.setRemoteNotificationSystem()`
     */
    public enum RemoteNotificationSystem {
        case apns
        
        @available(*, unavailable, renamed: "apns")
        case APNS
        
        case fcm
        
        case none
        
        @available(*, unavailable, renamed: "none")
        case NONE
    }

}

/**
 `RoxchatSession` builder.
 - seealso:
 `Roxchat.newSessionBuilder()`
 */
public final class SessionBuilder  {

    // MARK: - Properties
    private var accountName: String?
    private var appVersion: String?
    private var deviceToken: String?
    private weak var fatalErrorHandler: FatalErrorHandler?
    private var localHistoryStoragingEnabled = true
    private var location: String?
    private var mobileChatInstance: String?
    private var multivisitorSection = ""
    private weak var notFatalErrorHandler: NotFatalErrorHandler?
    private var pageTitle: String?
    private var providedAuthorizationToken: String?
    private weak var providedAuthorizationTokenStateListener: ProvidedAuthorizationTokenStateListener?
    private var remoteNotificationSystem: Roxchat.RemoteNotificationSystem = .none
    private var visitorDataClearingEnabled = false
    private var visitorFields: ProvidedVisitorFields?
    private weak var roxchatLogger: RoxchatLogger?
    private var roxchatLoggerVerbosityLevel: RoxchatLoggerVerbosityLevel?
    private var availableLogTypes = [RoxchatLogType]()
    private weak var roxchatAlert: RoxchatAlert?
    private var prechat: String?
    private var onlineStatusRequestFrequencyInMillis: Int64?
    private var requestHeader: [String: String]?

    // MARK: - Methods

    /**
     Sets company account name in Roxchat system.
     Usually presented by full domain URL of the server (e.g "https://demo.rox.chat").
     For testing purposes it is possible to use account name "demo".
     - parameter accountName:
     Roxchat account name.
     - returns:
     `SessionBuilder` object with account name set.
     */
    public func set(accountName: String) -> SessionBuilder {
        self.accountName = accountName

        return self
    }

    /**
     Location on server.
     You can use "mobile" or contact support for creating new one.
     - parameter location:
     Location name.
     - returns:
     `SessionBuilder` object with location set.
     - seealso:
     https://rox.chat/help/help-terms/#location
     */
    public func set(location: String) -> SessionBuilder {
        self.location = location

        return self
    }
    
    /**
     Mobile chat instance.
     Use this parameter for set new session inside mobile application.
     
     Default value is `default`.
     If you don't set this parameter and try to create new session inside mobile application you will get same session.
     - parameter location:
     Mobile location name.
     - returns:
     `SessionBuilder` object with location set.
     */
    public func set(mobileChatInstance: String) -> SessionBuilder {
        self.mobileChatInstance = mobileChatInstance

        return self
    }

    /**
     Set prechat fields with extra information.
     - parameter prechat:
     Prechat fields in JSON format.
     - returns:
     `SessionBuilder` object with location set.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    public func set(prechat: String) -> SessionBuilder {
        self.prechat = prechat
        return self
    }

    /**
     You can differentiate your app versions on server by setting this parameter. E.g. "2.9.11".
     This is optional.
     - parameter appVersion:
     Client app version name.
     - returns:
     `SessionBuilder` object with app version set.
     */
    public func set(appVersion: String?) -> SessionBuilder {
        self.appVersion = appVersion

        return self
    }

    /**
     A visitor can be anonymous or authorized. Without calling this method when creating a session visitor is anonymous.
     In this case visitor receives a random ID, which is written in `WMKeychainWrapper`. If the data is lost (for example when application was reinstalled), the user ID is also lost, as well as the message history.
     Authorizing of a visitor can be useful when there are internal mechanisms of authorization in your application and you want the message history to exist regardless of a device communication occurs from.
     This method takes as a parameter a string containing the signed fields of a user in JSON format. Since the fields are necessary to be signed with a private key that can never be included into the code of a client's application, this string must be created and signed somewhere on your backend side. Read more about forming a string and a signature here: https://rox.chat/help/identification/
     - important:
     Can't be used simultanously with `set(providedAuthorizationTokenStateListener:providedAuthorizationToken:)`.
     - parameter jsonString:
     JSON-string containing the signed fields of a visitor.
     - returns:
     `SessionBuilder` object with visitor fields set.
     - SeeAlso:
     https://rox.chat/help/identification/
     set(visitorFieldsJSONdata:)
     */
    public func set(visitorFieldsJSONString: String) -> SessionBuilder {
        self.visitorFields = ProvidedVisitorFields(withJSONString: visitorFieldsJSONString)

        return self
    }

    /**
     A visitor can be anonymous or authorized. Without calling this method when creating a session visitor is anonymous.
     In this case visitor receives a random ID, which is written in `WMKeychainWrapper`. If the data is lost (for example when application was reinstalled), the user ID is also lost, as well as the message history.
     Authorizing of a visitor can be useful when there are internal mechanisms of authorization in your application and you want the message history to exist regardless of a device communication occurs from.
     This method takes as a parameter a string containing the signed fields of a user in JSON format. Since the fields are necessary to be signed with a private key that can never be included into the code of a client's application, this string must be created and signed somewhere on your backend side. Read more about forming a string and a signature here: https://rox.chat/help/identification/
     - important:
     Can't be used simultanously with `set(providedAuthorizationTokenStateListener:providedAuthorizationToken:)`.
     - parameter jsonData:
     JSON-data containing the signed fields of a visitor.
     - returns:
     `SessionBuilder` object with visitor fields set.
     - SeeAlso:
     `set(visitorFieldsJSONstring:)`
     */
    public func set(visitorFieldsJSONData: Data) -> SessionBuilder {
        self.visitorFields = ProvidedVisitorFields(withJSONObject: visitorFieldsJSONData)

        return self
    }

    /**
     When client provides custom visitor authorization mechanism, it can be realised by providing custom authorization token which is used instead of visitor fields.
     - important:
     Can't be used simultaneously with `set(visitorFields:)`.
     - parameter providedAuthorizationTokenStateListener:
     `ProvidedAuthorizationTokenStateListener` object.
     - parameter providedAuthorizationToken:
     Optional. Client generated provided authorization token. If it is not passed, library generates its own.
     - seealso:
     `ProvidedAuthorizationTokenStateListener`
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    public func set(providedAuthorizationTokenStateListener: ProvidedAuthorizationTokenStateListener?,
                    providedAuthorizationToken: String? = nil) -> SessionBuilder {
        self.providedAuthorizationTokenStateListener = providedAuthorizationTokenStateListener
        self.providedAuthorizationToken = providedAuthorizationToken

        return self
    }

    /**
     Sets the page title visible to an operator. In the web version of a chat it is a title of a web page a user opens a chat from.
     By default "iOS Client".
     - parameter pageTitle:
     Page title that visible to an operator.
     - returns:
     `SessionBuilder` object with page title set.
     */
    public func set(pageTitle: String?) -> SessionBuilder {
        self.pageTitle = pageTitle

        return self
    }

    /**
     Sets a fatal error handler. An error is considered fatal if after processing it the session can not be continued anymore.
     - parameter fatalErrorHandler:
     Fatal error handler.
     - returns:
     `SessionBuilder` object with fatal error handler set.
     */
    public func set(fatalErrorHandler: FatalErrorHandler?) -> SessionBuilder {
        self.fatalErrorHandler = fatalErrorHandler

        return self
    }
    
    public func set(notFatalErrorHandler: NotFatalErrorHandler) -> SessionBuilder {
        self.notFatalErrorHandler = notFatalErrorHandler
        
        return self
    }

    /**
     Roxchat service can send remote notifications when new messages are received in chat.
     By default it does not. You have to handle receiving by yourself.
     To differentiate notifications from your app and from Roxchat service check the field "from" (see `Roxchat.isRoxchat(remoteNotification:)`).
     - important:
     If remote notification system is set you must set device token.
     - parameter remoteNotificationSystem:
     Enum that indicates which system of remote notification is used. By default – `none` (remote notifications are not to be sent).
     - returns:
     `SessionBuilder` object with remote notification system set.
     */
    public func set(remoteNotificationSystem: Roxchat.RemoteNotificationSystem) -> SessionBuilder {
        self.remoteNotificationSystem = remoteNotificationSystem

        return self
    }

    /**
     Sets device token.
     Example that shows how to change device token for the proper formatted one:
     `let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()`
     - parameter deviceToken:
     Device token in hexadecimal format and without any spaces and service symbols.
     - returns:
     `SessionBuilder` object with device token set.
     - seealso:
     `setRemoteNotificationsSystem`
     */
    public func set(deviceToken: String?) -> SessionBuilder {
        self.deviceToken = deviceToken

        return self
    }

    /**
     By default a session stores a message history locally. This method allows to disable history storage.
     - important:
     Use only for debugging!
     - parameter isLocalHistoryStoragingEnabled:
     Boolean parameter that indicated if an app should enable or disable local history storing.
     - returns:
     `SessionBuilder` object with isLocalHistoryStoragingEnabled parameter set.
     */
    public func set(isLocalHistoryStoragingEnabled: Bool) -> SessionBuilder {
        self.localHistoryStoragingEnabled = isLocalHistoryStoragingEnabled

        return self
    }

    /**
     If set to true, all the visitor data is cleared before the session starts.
     - important:
     Use only for debugging!
     - parameter isVisitorDataClearingEnabled:
     Boolean parameter that indicated if an app should clear visitor data before session starts.
     - returns:
     `SessionBuilder` object with isVisitorDataClearingEnabled parameter set.
     */
    public func set(isVisitorDataClearingEnabled: Bool) -> SessionBuilder {
        self.visitorDataClearingEnabled = isVisitorDataClearingEnabled

        return self
    }
    
    /**
     If set to true, different visitors can receive remote notifications on one device.
     - parameter isMultivisitor:
     Boolean parameter that indicated if an app should receive remote notifications for different visitors.
     - returns:
     `SessionBuilder` object with isVisitorDataClearingEnabled parameter set.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    public func set(multivisitorSection: String) -> SessionBuilder {
        self.multivisitorSection = multivisitorSection
        
        return self
    }
    
    /**
     If is set, SDK will request online status every and fire listener.
     - parameter onlineStatusRequestFrequencyInMillis:
     Request location frequency to server in millis.
     - returns:
     `SessionBuilder` object with requestLocationFrequencyInMs parameter set.
     */
    public func set(onlineStatusRequestFrequencyInMillis: Int64) -> SessionBuilder {
        self.onlineStatusRequestFrequencyInMillis = onlineStatusRequestFrequencyInMillis
        
        return self
    }
    
    /**
     Adds header to network requests.
     - parameter requestHeader:
     Request header.
     - returns:
     `SessionBuilder` object with requestLocationFrequencyInMs parameter set.
     */
    public func set(requestHeader: [String: String]) -> SessionBuilder {
        self.requestHeader = requestHeader
        
        return self
    }


    /**
     Method to pass RoxchatLogger object.
     - parameter roxchatLogger:
     `RoxchatLogger` object.
     - returns:
     `SessionBuilder` object with `RoxchatLogger` object set.
     - seealso:
     `RoxchatLogger`
     */
    public func set(roxchatLogger: RoxchatLogger?,
                    verbosityLevel: RoxchatLoggerVerbosityLevel = .warning,
                    availableLogTypes: [RoxchatLogType] = []) -> SessionBuilder {
        self.roxchatLogger = roxchatLogger
        self.availableLogTypes = availableLogTypes
        roxchatLoggerVerbosityLevel = verbosityLevel

        return self
    }
    
    /**
     Method to pass RoxchatLogger object.
     - parameter roxchatLogger:
     `RoxchatLogger` object.
     - returns:
     `SessionBuilder` object with `RoxchatLogger` object set.
     - seealso:
     `RoxchatLogger`
     */
    public func set(roxchatAlert: RoxchatAlert) -> SessionBuilder {
        self.roxchatAlert = roxchatAlert

        return self
    }

    /**
     Builds new `RoxchatSession` object.
     - important:
     All the follow-up work with the session must be implemented from the same thread this method was called in.
     Notice that a session is created as a paused. To start using it the first thing to do is to call `RoxchatSession.resume()`.
     - returns:
     New `RoxchatSession` object.
     - throws:
     `SessionBuilder.SessionBuilderError.nilAccountName` if account name wasn't set to a non-nil value.
     `SessionBuilder.SessionBuilderError.nilLocation` if location wasn't set to a non-nil value.
     `SessionBuilder.SessionBuilderError.invalidRemoteNotificationConfiguration` if there is a try to pass device token with `RemoteNotificationSystem` not set (or set to `.none`).
     `SessionBuilder.SessionBuilderError.invalidAuthentificatorParameters` if methods `set(visitorFieldsJSONString:)` or `set(visitorFieldsJSONData:)` are called with `set(providedAuthorizationTokenStateListener:,providedAuthorizationToken:)` simultaneously.
     - seealso:
     `SessionBuilder.SessionBuilderError`
     */
    public func build() throws -> RoxchatSession {
        guard let accountName = accountName else {
            throw SessionBuilderError.nilAccountName
        }
        guard let location = location else {
            throw SessionBuilderError.nilLocation
        }

        let remoteNotificationsEnabled = (self.remoteNotificationSystem != Roxchat.RemoteNotificationSystem.none)
        if (deviceToken != nil)
            && !remoteNotificationsEnabled {
            throw SessionBuilderError.invalidRemoteNotificationConfiguration
        }

        if (visitorFields != nil)
            && (providedAuthorizationTokenStateListener != nil) {
            throw SessionBuilderError.invalidAuthentificatorParameters
        }
        
        if let listener = providedAuthorizationTokenStateListener, self.providedAuthorizationToken == nil {
            listener.update(providedAuthorizationToken: ClientSideID.generateClientSideID())
        }
        
        if var prechat = self.prechat {
            if !prechat.contains(":") {
                //not json or string data
                if prechat.count % 2 != 0 {
                    throw SessionBuilderError.invalidHex
                }
                var byteArray = [UInt8]()
                var index = prechat.startIndex
                byteArray.reserveCapacity(prechat.count/2)
                for _ in 0..<prechat.count / 2 {
                    let nextIndex = prechat.index(index, offsetBy: 2)
                    if let b = UInt8(prechat[index..<nextIndex], radix: 16) {
                        byteArray.append(b)
                    } else {
                        throw SessionBuilderError.invalidHex
                    }
                    
                    index = nextIndex
                }
                let data = Data(_: byteArray)
                prechat = String(data:data, encoding: .utf8) ?? ""
                print("prechat parsed: \(prechat)")
            }
            //prechat is json or string data
            if !prechat.contains("{") {
                // not json
                let pairs = prechat.components(separatedBy: "\\n").map{pair in
                    pair.split(separator: ":").map(String.init)
                }
                let hasError = pairs.contains { pair in
                    pair.count != 2
                }
                if hasError {
                    throw SessionBuilderError.invalidHex
                }
                let result = pairs.map { pair in
                    "\"\(pair[0])\": \"\(pair[1])\""
                }.joined(separator: ", ")
                
                self.prechat = "{\(result)}"
                print("json: \(self.prechat ?? "{}")")
            }
        }

        return RoxchatSessionImpl.newInstanceWith(accountName: accountName,
                                                  location: location,
                                                  mobileChatInstance: mobileChatInstance,
                                                  appVersion: appVersion,
                                                  visitorFields: visitorFields,
                                                  providedAuthorizationTokenStateListener: providedAuthorizationTokenStateListener,
                                                  providedAuthorizationToken: providedAuthorizationToken,
                                                  pageTitle: pageTitle,
                                                  fatalErrorHandler: fatalErrorHandler,
                                                  notFatalErrorHandler: notFatalErrorHandler,
                                                  deviceToken: deviceToken,
                                                  remoteNotificationSystem: remoteNotificationSystem,
                                                  isLocalHistoryStoragingEnabled: localHistoryStoragingEnabled,
                                                  isVisitorDataClearingEnabled: visitorDataClearingEnabled,
                                                  roxchatLogger: roxchatLogger,
                                                  verbosityLevel: roxchatLoggerVerbosityLevel,
                                                  availableLogTypes: availableLogTypes,
                                                  roxchatAlert: roxchatAlert,
                                                  prechat: prechat,
                                                  multivisitorSection: multivisitorSection,
                                                  onlineStatusRequestFrequencyInMillis: onlineStatusRequestFrequencyInMillis,
                                                  requestHeader: requestHeader) as RoxchatSession
    }
    
    /**
    Builds new `RoxchatSession` object with callback
     - important:
     All the follow-up work with the session must be implemented from the same thread this method was called in.
     Notice that a session is created as a paused. To start using it the first thing to do is to call `RoxchatSession.resume()`.
     - parameter onSuccess:
     Clousure which will be executed when session sucessfully builded.
     Returns `RoxchatSession` object.
     - parameter onError:
     Clousure which will be executed when session building failed.
     Returns cause of failure as `SessionBuilder.SessionBuilderError` object.
     - seealso:
     `build()`
     `SessionBuilder.SessionBuilderError`
    */
    public func build(onSuccess: @escaping (RoxchatSession) -> (),
               onError: @escaping (SessionBuilder.SessionBuilderError) -> ()) {
        do {
            let roxchatSession = try self.build()
            onSuccess(roxchatSession)
        } catch let error as SessionBuilder.SessionBuilderError {
            onError(error)
        } catch {
            onError(.unknown)
        }
    }

    // MARK: -
    /**
     Verbosity level of `RoxchatLogger`.
     - seealso:
     `SessionBuilder.set(roxchatLogger:verbosityLevel:availableLogTypes:)`
     */
    public enum RoxchatLoggerVerbosityLevel {

        /**
         All available information will be delivered to `RoxchatLogger` instance with maximum verbosity level:
         * session network setup parameters;
         * network requests' URLs, HTTP method and parameters;
         * network responses' HTTP codes, received data and errors;
         * SQL queries and errors;
         * full debug information and additional notes.
         */
        case verbose
        
        @available(*, unavailable, renamed: "verbose")
        case VERBOSE

        /**
         All information which is useful when debugging will be delivered to `RoxchatLogger` instance with necessary verbosity level:
         * session network setup parameters;
         * network requests' URLs, HTTP method and parameters;
         * network responses' HTTP codes, received data and errors;
         * SQL queries and errors;
         * moderate debug information.
         */
        case debug
        
        @available(*, unavailable, renamed: "debug")
        case DEBUG

        /**
         Reference information and all warnings and errors will be delivered to `RoxchatLogger` instance:
         * network requests' URLS, HTTP method and parameters;
         * HTTP codes and errors descriptions of failed requests.
         * SQL errors.
         */
        case info
        
        @available(*, unavailable, renamed: "info")
        case INFO

        /**
         Errors and warnings only will be delivered to `RoxchatLogger` instance:
         * network requests' URLs, HTTP method, parameters, HTTP code and error description.
         * SQL errors.
         */
        case warning
        
        @available(*, unavailable, renamed: "warning")
        case WARNING

        /**
         Only errors will be delivered to `RoxchatLogger` instance:
         * network requests' URLs, HTTP method, parameters, HTTP code and error description.
         */
        case error
        
        @available(*, unavailable, renamed: "error")
        case ERROR

    }

    /**
     Log type of `RoxchatLogger`.
     - seealso:
     `SessionBuilder.set(roxchatLogger:verbosityLevel:availableLogTypes:)`
     */
    public enum RoxchatLogType {

        /**
         Log type associated with network requests.
         */
        case networkRequest

        /**
         Log type associated with message history.
         */
        case messageHistory

        /**
         Log type associated with method, that manual call.
         */
        case manualCall

        /**
         Undefined log type.
         */
        case undefined
    }

    /**
     Error types that can be thrown by `SessionBuilder` `build()` method.
     - seealso:
     `SessionBuilder.build()`
     */
    public enum SessionBuilderError: Error {

        /**
         Error that is thrown when trying to use standard and custom visitor fields authentication simultaneously.
         - seealso:
         `set(visitorFieldsJSONString:)`
         `set(visitorFieldsJSONData:)`
         `set(providedAuthorizationTokenStateListener:providedAuthorizationToken:)`
         */
        case invalidAuthentificatorParameters
        
        @available(*, unavailable, renamed: "invalidAuthentificatorParameters")
        case INVALID_AUTHENTICATION_PARAMETERS

        /**
         Error that is thrown when trying to create session object with invalid remote notifications configuration.
         - seealso:
         `set(remoteNotificationSystem:)`
         `set(deviceToken:)`
         */
        case invalidRemoteNotificationConfiguration
        
        @available(*, unavailable, renamed: "invalidRemoteNotificationConfiguration")
        case INVALID_REMOTE_NOTIFICATION_CONFIGURATION

        /**
         Error that is thrown when trying to create session object with `nil` account name.
         - seealso:
         `set(accountName:)`
         */
        case nilAccountName
        
        @available(*, unavailable, renamed: "nilAccountName")
        case NIL_ACCOUNT_NAME

        /**
         Error that is thrown when trying to create session object with `nil` location name.
         - seealso:
         `set(location:)`
         */
        case nilLocation
        
        @available(*, unavailable, renamed: "nilLocation")
        case NIL_LOCATION
        
        case invalidHex
        
        @available(*, unavailable, renamed: "invalidHex")
        case INVALIDE_HEX
        
        case unknown
        
        @available(*, unavailable, renamed: "unknown")
        case UNKNOWN

    }

}

/**
 `FAQ` builder.
 - seealso:
 `Roxchat.newFAQBuilder()`
 - attention:
 This class can't be used as is. It requires that client server to support this mechanism.
 */
public final class FAQBuilder  {
    
    // MARK: - Properties
    private var accountName: String?
    private var application: String?
    private var departmentKey: String?
    private var language: String?
    // MARK: - Methods
    
    /**
     Sets company account name in FAQ system.
     - parameter accountName:
     Roxchat account name.
     - returns:
     `FAQBuilder` object with account name set.
     */
    public func set(accountName: String) -> FAQBuilder {
        self.accountName = accountName
        
        return self
    }
    
    public func set(application: String) -> FAQBuilder {
        self.application = application
        
        return self
    }
    
    public func set(departmentKey: String) -> FAQBuilder {
        self.departmentKey = departmentKey
        
        return self
    }
    
    public func set(language: String) -> FAQBuilder {
        self.language = language
        
        return self
    }
    
    /**
     Builds new `FAQ` object.
     - important:
     All the follow-up work with the FAQ must be implemented from the same thread this method was called in.
     Notice that a FAQ is created as a paused. To start using it the first thing to do is to call `FAQ.resume()`.
     - returns:
     New `FAQ` object.
     - throws:
     `SessionBuilder.SessionBuilderError.nilAccountName` if account name wasn't set to a non-nil value.
     - seealso:
     `FAQBuilder.FAQBuilderError`
     */
    public func build() throws -> FAQ {
        guard let accountName = accountName else {
            throw FAQBuilderError.nilAccountName
        }
        
        return FAQImpl.newInstanceWith(accountName: accountName,
                                       application: application,
                                       departmentKey: departmentKey,
                                       language: language) as FAQ
    }
    
    /**
     Error types that can be thrown by `FAQBuilder` `build()` method.
     - seealso:
     `FAQBuilder.build()`
     */
    public enum FAQBuilderError: Error {
        
        /**
         Error that is thrown when trying to create faq object with `nil` account name.
         - seealso:
         `set(accountName:)`
         */
        case nilAccountName
        
        @available(*, unavailable, renamed: "nilAccountName")
        case NIL_ACCOUNT_NAME
        
    }
    
}

