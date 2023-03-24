
import Foundation
import RoxchatClientLibrary

final class RoxchatService {
    
    // MARK: - Constants
    public enum ChatSettings: Int {
        case messagesPerRequest = 25
    }
    
    // MARK: - Private Properties
    private weak var fatalErrorHandlerDelegate: FatalErrorHandlerDelegate?
    private weak var departmentListHandlerDelegate: DepartmentListHandlerDelegate?
    private weak var notFatalErrorHandler: NotFatalErrorHandler?
    private var messageStream: MessageStream?
    private var messageTracker: MessageTracker?
    private var roxchatSession: RoxchatSession?
    
    // MARK: - Initialization
    init(fatalErrorHandlerDelegate: FatalErrorHandlerDelegate,
         departmentListHandlerDelegate: DepartmentListHandlerDelegate) {
        self.fatalErrorHandlerDelegate = fatalErrorHandlerDelegate
        self.departmentListHandlerDelegate = departmentListHandlerDelegate
    }
    
    init(fatalErrorHandlerDelegate: FatalErrorHandlerDelegate,
         departmentListHandlerDelegate: DepartmentListHandlerDelegate,
         notFatalErrorHandler: NotFatalErrorHandler?) {
        self.fatalErrorHandlerDelegate = fatalErrorHandlerDelegate
        self.departmentListHandlerDelegate = departmentListHandlerDelegate
        self.notFatalErrorHandler = notFatalErrorHandler
    }
    
    func sessionState() -> ChatState {
        return roxchatSession?.getStream().getChatState() ?? .unknown
    }
    
    func createTestUserData() -> String {
        // !!!secretString MUST NOT be used in real application!!!
        let secretString = "64f7099e123231123123123121"
        var properties = [String: String]()

        properties["id"] = "test_id"
        properties["display_name"] = "test_name"
        
        var keys = Array(properties.keys)
        keys.sort()
        var stringToSign = ""
        for key in keys {
            stringToSign += properties[key]!
        }
        
        let crc = stringToSign.hmacSHA256(withKey: secretString)
        properties["crc"] = crc
        
        let jsonData = try! JSONSerialization.data(withJSONObject: properties, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!

        return jsonString
    }

    // MARK: - Methods
    func createSession() {
        
        let deviceToken: String? = WMKeychainWrapper.standard.string(forKey: WMKeychainWrapper.deviceTokenKey)
        
        let sessionBuilder = Roxchat.newSessionBuilder()
            .set(accountName: Settings.shared.accountName)
            .set(location: Settings.shared.location)
            .set(pageTitle: Settings.shared.pageTitle)
            .set(fatalErrorHandler: self)
            .set(remoteNotificationSystem: ((deviceToken != nil) ? .apns : .none))
            .set(deviceToken: deviceToken)
            .set(isVisitorDataClearingEnabled: false)
            .set(roxchatLogger: RoxchatLogManager.shared,
                 verbosityLevel: .verbose,
                 availableLogTypes: [.networkRequest, .messageHistory, .manualCall, .undefined])
        
        if let notFatalErrorHandler = notFatalErrorHandler {
            _ = sessionBuilder.set(notFatalErrorHandler: notFatalErrorHandler)
        }
        
        // Only for development phase you can use this function to test generation visitorFieldsJSONString
        
        if !Settings.shared.userDataJson.isEmpty {
            _ = sessionBuilder.set(visitorFieldsJSONString: Settings.shared.userDataJson)
        }
        
        sessionBuilder.build(
            onSuccess: { [weak self] roxchatSession in
                guard let self = self else {
                    print("Roxchat session object creating failed because of RoxchatService is nil.")
                    return
                }
                self.roxchatSession = roxchatSession
            },
            onError: { error in
                switch error {
                case .nilAccountName:
                    print("Roxchat session object creating failed because of passing nil account name.")
                    
                case .nilLocation:
                    print("Roxchat session object creating failed because of passing nil location name.")
                    
                case .invalidRemoteNotificationConfiguration:
                    print("Roxchat session object creating failed because of invalid remote notifications configuration.")
                    
                case .invalidAuthentificatorParameters:
                    print("Roxchat session object creating failed because of invalid visitor authentication system configuration.")
                    
                case .invalidHex:
                    print("Roxchat can't parsed prechat fields")
                    
                case .unknown:
                    print("Roxchat session object creating failed with unknown error")
                }
            }
        )
    }
    
    func startSession() {
        do {
            try roxchatSession?.resume()
        } catch {
            self.printError(error: error, message: "Roxchat session starting/resuming")
        }
       
        startChat()
    }
    
    func stopSession() {
        do {
            try messageTracker?.destroy()
            try roxchatSession?.destroy()
        } catch let error as AccessError {
            switch error {
            case .invalidSession:
                // Ignored because if session is already destroyed, we don't care (it's the same thing that we try to achieve).
                
                break
            case .invalidThread:
                // Assuming to check concurrent calls of RoxchatClientLibrary methods.
                print("Roxchat session or message tracker destroing failed because it was called from a wrong thread.")
                
            }
        } catch {
            print("Roxchat session or message tracker destroing failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    func set(unreadByVisitorMessageCountChangeListener listener: UnreadByVisitorMessageCountChangeListener) {
        roxchatSession?.getStream().set(unreadByVisitorMessageCountChangeListener: listener)
    }
    
    func setMessageStream() {
        messageStream = roxchatSession?.getStream()
    }
    
    func setVisitorTyping(draft: String?) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            try messageStream?.setVisitorTyping(draftMessage: draft)
        } catch {
            self.printError(error: error, message: "Visitor status sending")
        }
    }
    
    func send(
        message: String,
        completion: (() -> Void)? = nil
    ) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            if shouldShowDepartmentSelection(),
                let departments = messageStream?.getDepartmentList() {
                departmentListHandlerDelegate?.showDepartmentsList(
                    departments,
                    action: { [weak self] departmentKey in
                        self?.startChat(
                            departmentKey: departmentKey,
                            message: message
                        )
                        completion?()
                    }
                )
            } else {
                _ = try messageStream?.send(message: message) // Returned message ID ignored.
                completion?()
            }
        } catch {
            self.printError(error: error, message: "Message sending")
        }
    }
    
    func searchMessagesBy(query: String, completionHandler: SearchMessagesCompletionHandler?) {
        
        do {
            if messageStream == nil {
                setMessageStream()
            }
            try messageStream?.searchStreamMessagesBy(query: query, completionHandler: completionHandler)
            
        } catch {
            self.printError(error: error, message: "Search")
        }
    }

    func getServerSideSettings(completionHandler: ServerSideSettingsCompletionHandler?) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            try messageStream?.getServerSideSettings(completionHandler: completionHandler)

        } catch {
            self.printError(error: error, message: "Getting Server side settings")
        }
    }
    
    func send(surveyAnswer: String, completionHandler: SendSurveyAnswerCompletionHandler?) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.send(
                surveyAnswer: surveyAnswer,
                completionHandler: completionHandler
            )
        } catch {
            self.printError(error: error, message: "Send survey answer")
        }
    }
    
    func send(
        file data: Data,
        fileName: String,
        mimeType: String,
        completionHandler: SendFileCompletionHandler
    ) {
        if messageStream == nil {
            setMessageStream()
        }
        
        if shouldShowDepartmentSelection(),
            let departments = messageStream?.getDepartmentList() {
            departmentListHandlerDelegate?.showDepartmentsList(
                departments,
                action: { [weak self] departmentKey in
                    self?.startChat(
                        departmentKey: departmentKey,
                        message: nil
                    )
                    self?.sendFile(
                        data: data,
                        fileName: fileName,
                        mimeType: mimeType,
                        completionHandler: completionHandler
                    )
                }
            )
        } else {
            sendFile(
                data: data,
                fileName: fileName,
                mimeType: mimeType,
                completionHandler: completionHandler
            )
        }
    }
    
    func reply(
        message: String,
        repliedMessage: Message,
        completion: (() -> Void)? = nil
    ) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            if shouldShowDepartmentSelection(),
                let departments = messageStream?.getDepartmentList() {
                departmentListHandlerDelegate?.showDepartmentsList(
                    departments,
                    action: { [weak self] departmentKey in
                        self?.startChat(
                            departmentKey: departmentKey
                        )
                        self?.replyMessage(
                            message: message,
                            repliedMessage: repliedMessage
                        )
                    }
                )
            } else {
                replyMessage(
                    message: message,
                    repliedMessage: repliedMessage
                )
            }
        }
    }
    
    func edit(
        message: Message,
        text: String,
        completionHandler: EditMessageCompletionHandler
    ) {
        if messageStream == nil {
            setMessageStream()
        }
        
        if shouldShowDepartmentSelection(),
            let departments = messageStream?.getDepartmentList() {
            departmentListHandlerDelegate?.showDepartmentsList(
                departments,
                action: { [weak self] departmentKey in
                    self?.startChat(
                        departmentKey: departmentKey,
                        message: nil
                    )
                    self?.editMessage(
                        message: message,
                        text: text,
                        completionHandler: completionHandler
                    )
                }
            )
        } else {
            editMessage(
                message: message,
                text: text,
                completionHandler: completionHandler
            )
        }
    }
    
    func delete(
        message: Message,
        completionHandler: DeleteMessageCompletionHandler
    ) {
        if messageStream == nil {
            setMessageStream()
        }
        
        if shouldShowDepartmentSelection(),
            let departments = messageStream?.getDepartmentList() {
            departmentListHandlerDelegate?.showDepartmentsList(
                departments,
                action: { [weak self] departmentKey in
                    self?.startChat(departmentKey: departmentKey)
                    
                    self?.deleteMessage(
                        message: message,
                        completionHandler: completionHandler
                    )
                }
            )
        } else {
            deleteMessage(
                message: message,
                completionHandler: completionHandler
            )
        }
    }
    
    func react(
        reaction: ReactionString,
        message: Message,
        completionHandler: ReactionCompletionHandler
    ) {
        if messageStream == nil {
            setMessageStream()
        }
        
        if shouldShowDepartmentSelection(),
           let departments = messageStream?.getDepartmentList() {
            departmentListHandlerDelegate?.showDepartmentsList(
                departments,
                action: { [weak self] departmentKey in
                    self?.startChat(departmentKey: departmentKey)
                    
                    self?.setReaction(
                        message: message,
                        reaction: reaction,
                        completionHandler: completionHandler
                    )
                }
            )
        } else {
            self.setReaction(
                message: message,
                reaction: reaction,
                completionHandler: completionHandler
            )
        }
    }
    
    func isChatExist() -> Bool {
        guard let chatState = messageStream?.getChatState() else {
            return false
        }
        
        return ((chatState == .chatting)
            || (chatState == .closedByOperator))
    }
    
    func closeChat() {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.closeChat()
        } catch {
            self.printError(error: error, message: "Close chat")
        }
    }
    
    func clearHistory() {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.clearHistory()
        } catch let error as AccessError {
            switch error {
            case .invalidSession:
                // Assuming to check Roxchat session object lifecycle or re-creating Roxchat session object.
                print("Roxchat session starting/resuming failed because it was called when session object is invalid.")
                
            case .invalidThread:
                // Assuming to check concurrent calls of RoxchatClientLibrary methods.
                print("Roxchat session starting/resuming failed because it was called from a wrong thread.")
                
            }
        } catch {
            print("Roxchat session starting/resuming failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    func rateOperator(
        withID operatorID: String,
        byRating rating: Int,
        completionHandler: RateOperatorCompletionHandler?
    ) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.rateOperatorWith(
                id: operatorID,
                byRating: rating,
                completionHandler: completionHandler
            )
        } catch {
            self.printError(error: error, message: "Rate operator")
        }
    }
    
    func setHelloMessageListener(with helloMessageListener: HelloMessageListener) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(helloMessageListener: helloMessageListener)
    }
    
    func setMessageTracker(withMessageListener messageListener: MessageListener) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageTracker = messageStream?.newMessageTracker(
                messageListener: messageListener
            )
        } catch {
            self.printError(error: error, message: "Set message tracker")
        }
    }
    
    func getLastMessages(completion: @escaping (_ result: [Message]) -> Void) {
        do {
            try messageTracker?.getLastMessages(
                byLimit: ChatSettings.messagesPerRequest.rawValue,
                completion: completion
            )
        } catch {
            self.printError(error: error, message: "Get last messages")
        }
    }
    
    func getNextMessages(completion: @escaping (_ result: [Message]) -> Void) {
        do {
            try messageTracker?.getNextMessages(
                byLimit: ChatSettings.messagesPerRequest.rawValue,
                completion: completion
            )
        } catch {
            self.printError(error: error, message: "Get next messages")
        }
    }
    
    func setChatRead() {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.setChatRead()
        } catch {
            print("Read chat failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    func getUnreadMessagesByVisitor() -> Int {
        if messageStream == nil {
            setMessageStream()
        }
        return messageStream?.getUnreadByVisitorMessageCount() ?? 0
    }
    
    func set(operatorTypingListener: OperatorTypingListener) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(operatorTypingListener: operatorTypingListener)
    }
    
    func set(currentOperatorChangeListener: CurrentOperatorChangeListener) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(currentOperatorChangeListener: currentOperatorChangeListener)
    }
    
    func getCurrentOperator() -> Operator? {
        if messageStream == nil {
            setMessageStream()
        }
        return messageStream?.getCurrentOperator()
    }
    
    func getLastRatingOfOperatorWith(id: String) -> Int {
        if messageStream == nil {
            setMessageStream()
        }
        return messageStream?.getLastRatingOfOperatorWith(id: id) ?? 0
    }
    
    func set(surveyListener: SurveyListener) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(surveyListener: surveyListener)
    }
    
    func set(chatStateListener: ChatStateListener) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(chatStateListener: chatStateListener)
    }
    
    func sendKeyboardRequest(
        button: KeyboardButton,
        message: Message,
        completionHandler: SendKeyboardRequestCompletionHandler
    ) {
        if messageStream == nil {
            setMessageStream()
        }
        
        if shouldShowDepartmentSelection(),
            let departments = messageStream?.getDepartmentList() {
            departmentListHandlerDelegate?.showDepartmentsList(
                departments,
                action: { [weak self] departmentKey in
                    self?.startChat(departmentKey: departmentKey)
                    
                    self?.sendKeyboard(
                        button: button,
                        message: message,
                        completionHandler: completionHandler
                    )
                }
            )
        } else {
            sendKeyboard(
                button: button,
                message: message,
                completionHandler: completionHandler
            )
        }
    }
    
    // MARK: Private methods
    
    private func startChat(
        departmentKey: String? = nil,
        message: String? = nil
    ) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.startChat(
                departmentKey: departmentKey,
                firstQuestion: message
            )
        } catch {
            self.printError(error: error, message: "Start chat")
        }
    }
    
    private func replyMessage(
        message: String,
        repliedMessage: Message
    ) {
        do {
            _ = try messageStream?.reply(
                message: message,
                repliedMessage: repliedMessage
            )
        } catch {
            self.printError(error: error, message: "Reply message")
        }
    }
    
    private func setReaction(
        message: Message,
        reaction: ReactionString,
        completionHandler: ReactionCompletionHandler?
    ) {
        do {
            _ = try messageStream?.react(
                message: message,
                reaction: reaction,
                completionHandler: completionHandler
            )
        } catch let error as AccessError {
            switch error {
            case .invalidSession:
                // Assuming to check Roxchat session object lifecycle or re-creating Roxchat session object.
                print("Message editing failed because it was called when session object is invalid.")
            case .invalidThread:
                // Assuming to check concurrent calls of RoxchatClientLibrary methods.
                print("Message editing failed because it was called from a wrong thread.")
            }
        } catch {
            print("Message status editing failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    private func sendFile(
        data: Data,
        fileName: String,
        mimeType: String,
        completionHandler: SendFileCompletionHandler
    ) {
        do {
            _ = try messageStream?.send(
                file: data,
                filename: fileName,
                mimeType: mimeType,
                completionHandler: completionHandler
            )  // Returned message ID ignored.
        } catch {
            self.printError(error: error, message: "Send file")
        }
    }
    
    private func editMessage(
        message: Message,
        text: String,
        completionHandler: EditMessageCompletionHandler
    ) {
        do {
            _ = try messageStream?.edit(
                message: message,
                text: text,
                completionHandler: completionHandler
            )
        } catch {
            self.printError(error: error, message: "Edit message")
        }
    }
    
    private func deleteMessage(
        message: Message,
        completionHandler: DeleteMessageCompletionHandler
    ) {
        do {
            _ = try messageStream?.delete(
                message: message,
                completionHandler: completionHandler
            )
        } catch {
            self.printError(error: error, message: "Delete message")
        }
    }
    
    private func sendKeyboard(
        button: KeyboardButton,
        message: Message,
        completionHandler: SendKeyboardRequestCompletionHandler
    ) {
        do {
            _ = try messageStream?.sendKeyboardRequest(
                button: button,
                message: message,
                completionHandler: completionHandler
            )
        } catch {
            self.printError(error: error, message: "Sending keyboard request")
        }
    }
    
    func shouldShowDepartmentSelection() -> Bool {
        return messageStream?.getVisitSessionState() == .departmentSelection || messageStream?.getVisitSessionState() == .idleAfterChat
    }
    
    func printError(error: Error, message: String) {
        switch error {
        case AccessError.invalidSession:
            // Assuming to check Roxchat session object lifecycle or re-creating Roxchat session object.
            print(message + " failed because it was called when session object is invalid.")
        case AccessError.invalidThread:
            // Assuming to check concurrent calls of RoxchatClientLibrary methods.
            print(message + " failed because it was called from a wrong thread.")
        default :
            print(message + " failed with unknown error: \(error.localizedDescription)")
        }
    }
    
}

extension RoxchatService: FatalErrorHandler {
    
    // MARK: - Methods
    func on(error: RoxchatError) {
        let errorType = error.getErrorType()
        switch errorType {
        case .accountBlocked:
            // Assuming to contact with Roxchat support.
            print("Account with used account name is blocked by Roxchat service.")
            fatalErrorHandlerDelegate?.showErrorDialog(withMessage: "AccountBlocked".localized)
            
        case .providedVisitorFieldsExpired:
            // Assuming to re-authorize it and re-create session object.
            print("Provided visitor fields expired. See \"expires\" key of this fields.")
            
        case .unknown:
            print("An unknown error occured: \(error.getErrorString()).")
            
        case .visitorBanned:
            print("Visitor with provided visitor fields is banned by an operator.")
            fatalErrorHandlerDelegate?.showErrorDialog(withMessage: "Your visitor account is in the black list.".localized)
            
        case .wrongProvidedVisitorHash:
            // Assuming to check visitor field generating.
            print("Wrong CRC passed with visitor fields.")
            
        }
    }
    
}

extension RoxchatService: NotFatalErrorHandler {
    
    func on(error: RoxchatNotFatalError) {
        self.notFatalErrorHandler?.on(error: error)
    }
    
    func connectionStateChanged(connected: Bool) {
        self.notFatalErrorHandler?.connectionStateChanged(connected: connected)
    }
    
}

protocol FatalErrorHandlerDelegate: AnyObject {
    
    // MARK: - Methods
    func showErrorDialog(withMessage message: String)
    
}

protocol DepartmentListHandlerDelegate: AnyObject {
    
    // MARK: - Methods
    func showDepartmentsList(
        _ departaments: [Department],
        action: @escaping (String) -> Void
    )
}

extension DepartmentListHandlerDelegate {
    func showDepartmentsList(_ departmentList: [Department], action: @escaping (String) -> Void) {}
}
