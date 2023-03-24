
import Foundation

/**
 - seealso:
 `RoxchatSession.getStream()`
 */
public protocol MessageStream: class {
    
    /**
     - seealso:
     `VisitSessionState` type.
     - returns:
     Current session state.
     */
    func getVisitSessionState() -> VisitSessionState
    
    /**
     - returns:
     Current chat state.
     - seealso:
     `ChatState` type.
     */
    func getChatState() -> ChatState
    
    /**
     - returns:
     Timestamp after which all chat messages are unread by operator (at the moment of last server update recieved).
     */
    func getUnreadByOperatorTimestamp() -> Date?
    
    /**
     - returns:
     Timestamp after which all chat messages are unread by visitor (at the moment of last server update recieved) or `nil` if there's no unread by visitor messages.
     */
    func getUnreadByVisitorTimestamp() -> Date?
    
    /**
     - returns:
     Count of unread by visitor messages (at the moment of last server update recieved).
     */
    func getUnreadByVisitorMessageCount() -> Int

    /**
     - seealso:
     `Department` protocol.
     `DepartmentListChangeListener` protocol.
     - returns:
     List of departments or `nil` if there're any or department list is not received yet.
     */
    func getDepartmentList() -> [Department]?
    
    /**
     - returns:
     Current LocationSettings of the MessageStream.
     */
    func getLocationSettings() -> LocationSettings
    
    /**
     - returns:
     Operator of the current chat.
     */
    func getCurrentOperator() -> Operator?
    
    /**
     - parameter id:
     ID of the operator.
     - returns:
     Previous rating of the operator or 0 if it was not rated before.
     */
    func getLastRatingOfOperatorWith(id: String) -> Int
    
    /**
     Rates an operator.
     To get an ID of the current operator call `getCurrentOperator()`.
     - important:
     Requires existing chat.
     - seealso:
     `RateOperatorCompletionHandler` protocol.
     - parameter id:
     ID of the operator to be rated. If passed `nil` current chat operator will be rated.
     - parameter rate:
     A number in range (1...5) that represents an operator rating. If the number is out of range, rating will not be sent to a server.
     - parameter comletionHandler:
     `RateOperatorCompletionHandler` object.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func rateOperatorWith(id: String?,
                          byRating rating: Int,
                          completionHandler: RateOperatorCompletionHandler?) throws
    
    /**
     Rates an operator.
     To get an ID of the current operator call `getCurrentOperator()`.
     - important:
     Requires existing chat.
     - seealso:
     `RateOperatorCompletionHandler` protocol.
     - parameter id:
     ID of the operator to be rated. If passed `nil` current chat operator will be rated.
     - parameter note:
     A comment for rating. Maximum length is 2000 characters.
     - parameter rate:
     A number in range (1...5) that represents an operator rating. If the number is out of range, rating will not be sent to a server.
     - parameter comletionHandler:
     `RateOperatorCompletionHandler` object.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func rateOperatorWith(id: String?,
                          note: String?,
                          byRating rating: Int,
                          completionHandler: RateOperatorCompletionHandler?) throws
    
    /**
     Respond sentry call
     - important:
     Id of redirect to sentry message
     - parameter id:
     ID of the operator to be rated. If passed `nil` current chat operator will be rated.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func respondSentryCall(id: String) throws
    
    /**
     Search messages in history by query.
     - parameter query:
     Query to be searched.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.INVALID_SESSION` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    
    func searchStreamMessagesBy(query: String, completionHandler: SearchMessagesCompletionHandler?) throws
    
    /**
     Changes `ChatState` to `ChatState.queue`.
     Can cause `VisitSessionState.departmentSelection` session state. It means that chat must be started by `startChat(departmentKey:)` method.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func startChat() throws
    
    /**
     Starts chat and sends first message simultaneously.
     Changes `ChatState` to `ChatState.queue`.
     - parameter firstQuestion:
     First message to send.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func startChat(firstQuestion: String?) throws
    
    /**
     Starts chat with particular department.
     Changes `ChatState` to `ChatState.queue`.
     - seealso:
     `Department` protocol.
     - parameter departmentKey:
     Department key (see `getKey()` of `Department` protocol). Calling this method without this parameter passed is the same as `startChat()` method is called.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func startChat(departmentKey: String?) throws

    
    /**
     Starts chat with custom fields.
     Changes `ChatState` to `ChatState.queue`.
     - parameter customFields:
     Custom fields in JSON format.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
    */
    func startChat(customFields: String?) throws
    
    /**
     Starts chat with particular department and sends first message simultaneously.
     Changes `ChatState` to `ChatState.queue`.
     - seealso:
     `Department` protocol.
     - parameter departmentKey:
     Department key (see `getKey()` of `Department` protocol). Calling this method without this parameter passed is the same as `startChat()` method is called.
     - parameter firstQuestion:
     First message to send.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func startChat(departmentKey: String?,
                   firstQuestion: String?) throws
    
    /**
     Starts chat with custom fields and sends first message simultaneously.
     Changes `ChatState` to `ChatState.queue`.
     - parameter firstQuestion:
     First message to send.
     - parameter customFields:
     Custom fields in JSON format.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func startChat(firstQuestion:String?,
                   customFields: String?) throws
    
    /**
     Starts chat with particular department and custom fields.
     Changes `ChatState` to `ChatState.queue`.
     - seealso:
     `Department` protocol.
     - parameter departmentKey:
     Department key (see `getKey()` of `Department` protocol). Calling this method without this parameter passed is the same as `startChat()` method is called.
     - parameter customFields:
     Custom fields in JSON format.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func startChat(departmentKey: String?,
                   customFields: String?) throws
    
    /**
     Starts chat with particular department and custom fields and sends first message simultaneously.
     Changes `ChatState` to `ChatState.queue`.
     - seealso:
     `Department` protocol.
     - parameter departmentKey:
     Department key (see `getKey()` of `Department` protocol). Calling this method without this parameter passed is the same as `startChat()` method is called.
     - parameter firstQuestion:
     First message to send.
     - parameter customFields:
     Custom fields in JSON format.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func startChat(departmentKey: String?,
                   firstQuestion: String?,
                   customFields: String?) throws
    
    
    /**
     Changes `ChatState` to `ChatState.closedByVisitor`.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func closeChat() throws
    
    /**
     This method must be called whenever there is a change of the input field of a message transferring current content of a message as a parameter.
     - parameter draftMessage:
     Current message content.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func setVisitorTyping(draftMessage: String?) throws
    
    /**
     Sends prechat fields to server.
     - parameter prechatFields:
     Custom fields.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func set(prechatFields: String) throws
    
    /**
     Sends a text message.
     When calling this method, if there is an active `MessageTracker` (see newMessageTracker(messageListener:)). `MessageListener.added(message:after:)`) with a message `MessageSendStatus.sending` in the status is also called.
     - important:
     Maximum length of message is 32000 characters. Longer messages will be clipped.
     - parameter message:
     Text of the message.
     - returns:
     ID of the message.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func send(message: String) throws -> String
    
    /**
    Sends a text message.
    When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.added(message:after:)`) with a message `MessageSendStatus.SENDING` in the status is also called.
    - important:
    Maximum length of message is 32000 characters. Longer messages will be clipped.
    - parameter message:
    Text of the message.
    - parameter completionHandler:
    Completion handler that executes when operation is done.
    - returns:
    ID of the message.
    - throws:
    `AccessError.INVALID_THREAD` if the method was called not from the thread the RoxchatSession was created in.
    `AccessError.INVALID_SESSION` if RoxchatSession was destroyed.
    */
    func send(message: String, completionHandler: SendMessageCompletionHandler?) throws -> String
    
    /**
     Sends a text message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.added(message:after:)`) with a message `MessageSendStatus.sending` in the status is also called.
     - important:
     Maximum length of message is 32000 characters. Longer messages will be clipped.
     - parameter message:
     Text of the message.
     - parameter data:
     Optional. Custom message parameters dictionary. Note that this functionality does not work as is – server version must support it.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     ID of the message.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func send(message: String,
              data: [String: Any]?,
              completionHandler: DataMessageCompletionHandler?) throws -> String
    
    /**
     Sends a text message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.added(message:after:)`) with a message `MessageSendStatus.sending` in the status is also called.
     - important:
     Maximum length of message is 32000 characters. Longer messages will be clipped.
     - parameter message:
     Text of the message.
     - parameter isHintQuestion:
     Optional. Shows to server if a visitor chose a hint (true) or wrote his own text (false).
     - returns:
     ID of the message.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func send(message: String,
              isHintQuestion: Bool?) throws -> String
    
    /**
     Sends a message with uploaded files.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.added(message:after:)`) with a message `MessageSendStatus.sending` in the status is also called.
     - seealso:
     Method could fail. See `SendFilesError`.
     - important:
     Maximum count of files is 10.
     - parameter uploadedFiles:
     Uploaded files for sending.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     ID of the message.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func send(uploadedFiles: [UploadedFile],
              completionHandler: SendFilesCompletionHandler?) throws -> String
    
    /**
     Sends a file message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method), `MessageListener.added(message:after:)` with a message `MessageSendStatus.sending` in the status is also called.
     - seealso:
     Method could fail. See `SendFileError`.
     - parameter file:
     File data to send
     - parameter filename:
     File name with file extension.
     - parameter mimeType:
     MIME type of the file to send.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     ID of the message.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func send(file: Data,
              filename: String,
              mimeType: String,
              completionHandler: SendFileCompletionHandler?) throws -> String
    
    /**
     Uploads a file to server.
     - seealso:
     Method could fail. See `SendFileError`.
     - parameter file:
     File data to send
     - parameter filename:
     File name with file extension.
     - parameter mimeType:
     MIME type of the file to send.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     ID of the message.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func uploadFilesToServer(file: Data,
                             filename: String,
                             mimeType: String,
                             completionHandler: UploadFileToServerCompletionHandler?) throws -> String

    /**
     Deletes uploaded file from server.
     - seealso:
     Method could fail. See `DeleteUploadedFileError`.
     - parameter fileGuid:
     GUID of file.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     ID of the message.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func deleteUploadedFiles(fileGuid: String,
                             completionHandler: DeleteUploadedFileCompletionHandler?) throws
    
    /**
     Send sticker to chat.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method), `MessageListener.added(message:after:)` with a message `MessageSendStatus.sending` in the status is also called.
     - parameter withId:
     Contains the id of the sticker to send
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func sendSticker(withId: Int,
                     completionHandler: SendStickerCompletionHandler?) throws
    
    /**
     Receive raw location config from server.
     - parameter forLocation:
     Contains the name of current location.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func getRawConfig(forLocation: String,
                      completionHandler: RawLocationConfigCompletionHandler?) throws
    /**
     Receive server side settings from server.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func getServerSideSettings(completionHandler: ServerSideSettingsCompletionHandler?) throws
    
    /**
     Send visitor react.
     - parameter message:
     Message to react.
     - parameter reaction:
     Visitor reaction.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    
    func react(message: Message,
               reaction: ReactionString,
               completionHandler: ReactionCompletionHandler?) throws -> Bool
    
    /**
     Send keyboard request with button.
     - parameter button:
     Selected button.
     - parameter message:
     Message with keyboard.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func sendKeyboardRequest(button: KeyboardButton,
                             message: Message,
                             completionHandler: SendKeyboardRequestCompletionHandler?) throws
    
    /**
     Send keyboard request with button.
     - parameter buttonID:
     ID of selected button.
     - parameter messageID:
     Current chat ID of message with keyboard.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func sendKeyboardRequest(buttonID: String,
                             messageCurrentChatID: String,
                             completionHandler: SendKeyboardRequestCompletionHandler?) throws
    
    /**
     Update widget status. The change is displayed by the operator.
     - parameter data:
     JSON string with new widget status.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func updateWidgetStatus(data: String) throws
    
    /**
     Reply a message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.added(message:after:)`) with a message `MessageSendStatus.sending` in the status is also called.
     - important:
     Maximum length of message is 32000 characters. Longer messages will be clipped.
     - parameter message:
     Text of the message.
     - parameter repliedMessage:
     Replied message.
     - returns:
     ID of the message or nil, if message can't be replied.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func reply(message: String,
               repliedMessage: Message) throws -> String?
    
    /**
     Edits a text message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.changed(oldVersion:newVersion:)`) with a message `MessageSendStatus.sending` in the status is also called.
     - important:
     Maximum length of message is 32000 characters. Longer messages will be clipped.
     - parameter message:
     ID of the message to edit.
     - parameter text:
     Text of the message.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     True if the message can be edited.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func edit(message: Message,
              text: String,
              completionHandler: EditMessageCompletionHandler?) throws -> Bool
    
    /**
     Deletes a message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.removed(message:)`) with a message `MessageSendStatus.sent` in the status is also called.
     - parameter message:
     The message to delete.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     True if the message can be deleted.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func delete(message: Message,
                completionHandler: DeleteMessageCompletionHandler?) throws -> Bool
    
    /**
     Set chat has been read by visitor.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func setChatRead() throws
    
    /**
     Send current dialog to email address.
     - parameter emailAddress:
     Email addres for sending.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func sendDialogTo(emailAddress: String,
                      completionHandler: SendDialogToEmailAddressCompletionHandler?) throws
    
    /**
     Send survey answer.
     important: radio button answer numeration starts from 1
     - parameter surveyAnswer
     Answer to survey. If question type is 'stars', answer is var 1-5 that corresponds the rating. If question type is 'radio', answer is index of element in options array beginning with 1. If question type is 'comment', answer is a string.
     - parameter completionHandler
     Completion handler that executes when operation is done.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func send(surveyAnswer: String,
              completionHandler: SendSurveyAnswerCompletionHandler?) throws

    /**
     Method closes current survey.
     - parameter completionHandler
     Completion handler that executes when operation is done.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func closeSurvey(completionHandler: SurveyCloseCompletionHandler?) throws
    
    /**
     Sends geolocation to server.
     - parameter latitude:
     Latitude of geo point.
     - parameter longitude:
     Longitude of geo point.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func sendGeolocation(latitude: Double,
                         longitude: Double,
                         completionHandler: GeolocationCompletionHandler?) throws

    /**
     Sets `SurveyListener` object.
     - seealso:
     `SurveyListener` protocol.
     - parameter surveyListener:
     `SurveyListener` object.
     */
    func set(surveyListener: SurveyListener)
    
    /**
     `MessageTracker` (via `MessageTracker.getNextMessages(byLimit:completion:)`) allows to request the messages which are above in the history. Each next call `MessageTracker.getNextMessages(byLimit:completion:)` returns earlier messages in relation to the already requested ones.
     Changes of user-visible messages (e.g. ever requested from `MessageTracker`) are transmitted to `MessageListener`. That is why `MessageListener` is needed when creating `MessageTracker`.
     - important:
     For each `MessageStream` at every single moment can exist the only one active `MessageTracker`. When creating a new one at the previous there will be automatically called `MessageTracker.destroy()`.
     - parameter messageListener:
     A listener of message changes in the tracking range.
     - returns:
     A new `MessageTracker` for this stream.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the RoxchatSession was created in.
     `AccessError.invalidSession` if RoxchatSession was destroyed.
     */
    func newMessageTracker(messageListener: MessageListener) throws -> MessageTracker
    
    /**
     Sets `VisitSessionStateListener` object.
     - seealso:
     `VisitSessionStateListener` protocol.
     `VisitSessionState` type.
     - parameter visitSessionStateListener:
     `VisitSessionStateListener` object.
     */
    func set(visitSessionStateListener: VisitSessionStateListener)
    
    /**
     Sets the `ChatState` change listener.
     - parameter chatStateListener:
     The `ChatState` change listener.
     */
    func set(chatStateListener: ChatStateListener)
    
    /**
     Sets the current `Operator` change listener.
     - parameter currentOperatorChangeListener:
     Current `Operator` change listener.
     */
    func set(currentOperatorChangeListener: CurrentOperatorChangeListener)
    
    /**
     Sets `DepartmentListChangeListener` object.
     - seealso:
     `DepartmentListChangeListener` protocol.
     `Department` protocol.
     - parameter departmentListChangeListener:
     `DepartmentListChangeListener` object.
     */
    func set(departmentListChangeListener: DepartmentListChangeListener)
    
    /**
     Sets the listener of the MessageStream LocationSettings changes.
     - parameter locationSettingsChangeListener:
     The listener of MessageStream LocationSettings changes.
     */
    func set(locationSettingsChangeListener: LocationSettingsChangeListener)
    
    /**
     Sets the listener of the "operator typing" status changes.
     - parameter operatorTypingListener:
     The listener of the "operator typing" status changes.
     */
    func set(operatorTypingListener: OperatorTypingListener)
    
    /**
     Sets the listener of session status changes.
     - parameter onlineStatusChangeListener:
     `OnlineStatusChangeListener` object.
     - seealso:
     `OnlineStatusChangeListener`
     */
    func set(onlineStatusChangeListener: OnlineStatusChangeListener)
    
    /**
     Sets listener for parameter that is to be returned by `MessageStream.getUnreadByOperatorTimestamp()` method.
     - parameter unreadByOperatorTimestampChangeListener:
     `UnreadByOperatorTimestampChangeListener` object.
     */
    func set(unreadByOperatorTimestampChangeListener: UnreadByOperatorTimestampChangeListener)
    
    /**
     Sets listener for parameter that is to be returned by `MessageStream.getUnreadByVisitorMessageCount()` method.
     - parameter unreadByVisitorMessageCountChangeListener:
     `UnreadByVisitorMessageCountChangeListener` object.
     */
    func set(unreadByVisitorMessageCountChangeListener: UnreadByVisitorMessageCountChangeListener)
    
    /**
     Sets listener for parameter that is to be returned by `MessageStream.getUnreadByVisitorTimestamp()` method.
     - parameter unreadByVisitorTimestampChangeListener:
     `UnreadByVisitorTimestampChangeListener` object.
     */
    func set(unreadByVisitorTimestampChangeListener: UnreadByVisitorTimestampChangeListener)
    
    /**
     Sets listener for hello message.
     - parameter helloMessageListener:
     `HelloMessageListener` object.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func set(helloMessageListener: HelloMessageListener)
    
    /**
     Called when user clear history.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func clearHistory() throws
    
}

/**
 Interface that provides methods for handling MessageStream LocationSettings which are received from server.
 - seealso:
 `LocationSettingsChangeListener`
 */
public protocol LocationSettings {
    
    /**
     This method shows to an app if it should show hint questions to visitor.
     - returns:
     True if an app should show hint questions to visitor, false otherwise.
     */
    func areHintsEnabled() -> Bool
    
}

/**
 - seealso:
 `MessageStream.send(message:data:completionHandler:)`.
 */
public protocol DataMessageCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `DataMessageError`.
     */
    func onFailure(messageID: String,
                   error: DataMessageError)
    
}

/**
 - seealso:
 `MessageStream.edit(message:messageID:completionHandler:)`.
 */
public protocol EditMessageCompletionHandler: class {
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `EditMessageError`.
     */
    func onFailure(messageID: String,
                   error: EditMessageError)
}

/**
 - seealso:
 `MessageStream.delete(messageID:completionHandler:)`.
 */
public protocol DeleteMessageCompletionHandler: class {
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `DeleteMessageError`.
     */
    func onFailure(messageID: String,
                   error: DeleteMessageError)
}

/**
- seealso:
`MessageStream.send(message:completionHandler:)`
*/
public protocol SendMessageCompletionHandler: class {
    func onSuccess(messageID: String)
}

/**
 - seealso:
 `MessageStream.send(file:filename:mimeType:completionHandler:)`
 */
public protocol SendFileCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `SendFileError`.
     */
    func onFailure(messageID: String,
                   error: SendFileError)
    
}

public protocol SendFilesCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `SendFileError`.
     */
    func onFailure(messageID: String,
                   error: SendFilesError)
    
}

public protocol UploadFileToServerCompletionHandler: class {
    /**
     Executed when operation is done successfully.
     - parameter id:
     ID of the message.
     - parameter uploadedFile:
     Uploaded file from server.
     */
    func onSuccess(id: String, uploadedFile: UploadedFile)

    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `SendFileError`.
     */
    func onFailure(messageID: String, error: SendFileError)
}

public protocol DeleteUploadedFileCompletionHandler: class {
    /**
     Executed when operation is done successfully.
     - parameter id:
     ID of the message.
     - parameter uploadedFile:
     Uploaded file from server.
     */
    func onSuccess()
    
    /**
     Executed when operation is failed.
     - parameter error:
     Error.
     - seealso:
     `SendFileError`.
     */
    func onFailure(error: DeleteUploadedFileError)
}
/**
 - seealso:
 `MessageStream.sendKeyboardRequest(button:message:completionHandler:)`
 */
public protocol SendKeyboardRequestCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `KeyboardResponseError`.
     */
    func onFailure(messageID: String,
                   error: KeyboardResponseError)
    
}

/**
 - seealso:
 `MessageStream.rateOperatorWith(id:byRating:completionHandler:)`.
 */
public protocol RateOperatorCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     */
    func onSuccess()
    
    /**
     Executed when operation is failed.
     - parameter error:
     Error.
     - seealso:
     `RateOperatorError`.
     */
    func onFailure(error: RateOperatorError)
    
}

/**
 - seealso:
 `MessageStream.sendDialogTo(emailAddress:completionHandler:)`.
 */
public protocol SendDialogToEmailAddressCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     */
    func onSuccess()
    
    /**
     Executed when operation is failed.
     - parameter error:
     Error.
     - seealso:
     `SendDialogToEmailAddressError`.
     */
    func onFailure(error: SendDialogToEmailAddressError)
    
}

/**
 - seealso:
 `MessageStream.searchStreamMessagesBy(query:completionHandler:)`.
 - attention:
 This protocol can't be used as is. It requires that client server to support this mechanism.
 */

public protocol SearchMessagesCompletionHandler: class {
    
    /** Executed after search message operation complited. */
    func onSearchMessageSuccess(query: String, messages: [Message])
    func onSearchMessageFailure(query: String)
}

/**
 - seealso:
 `MessageStream.sendSticker(withId:completionHandler:)`.
 - attention:
 This protocol can't be used as is. It requires that client server to support this mechanism.
 */
public protocol SendStickerCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     */
    func onSuccess()
    
    /**
     Executed when operation is failed.
     - parameter error:
     Error.
     - seealso:
     `SendStickerError`.
     */
    func onFailure(error: SendStickerError)
    
}

/**
 - seealso:
 `MessageStream.getRawConfig(forLocation:completionHandler:)`.
 - attention:
 This protocol can't be used as is. It requires that client server to support this mechanism.
 */
public protocol RawLocationConfigCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     - parameter rawLocationConfig:
     Location config.
     */
    func onSuccess(rawLocationConfig: [String: Any?])
    
    /**
     Executed when operation is failed.
     */
    func onFailure()
}

/**
 - seealso:
 `MessageStream.getServerSideSettings(completionHandler:)`.
 */
public protocol ServerSideSettingsCompletionHandler: class {
    /**
     Executed when operation is done successfully.
     - parameter roxchatServerSideSettings:
     Server side settings.
     */
    func onSuccess(roxchatServerSideSettings: RoxchatServerSideSettings)

    /**
     Executed when operation is failed.
     */
    func onFailure()
}

/**
- seealso:
`MessageStream.send(surveyAnswer:completionHandler:)`.
 - attention:
 This protocol can't be used as is. It requires that client server to support this mechanism.
*/
public protocol SendSurveyAnswerCompletionHandler {
    
    /**
     Executed when operation is done successfully.
     */
    func onSuccess()
    
    /**
     Executed when operation is failed.
     - parameter error:
     Error.
     - seealso:
     `SurveyAnswerError`.
     */
    func onFailure(error: SendSurveyAnswerError)
}

/**
- seealso:
`MessageStream.closeSurvey(completionHandler:)`.
- attention:
This protocol can't be used as is. It requires that client server to support this mechanism.
*/
public protocol SurveyCloseCompletionHandler {
    
    /**
     Invoked when survey was successfully closed on server.
     */
    func onSuccess()

    /**
     Invoked when an error occurred while closing a survey on server.
     */
    func onFailure(error: SurveyCloseError)
}

/**
 - seealso:
 `MessageStream.sendGeolocation(latitude:longtitude:completionHandler:)`.
 */
public protocol GeolocationCompletionHandler: class {
    
    /**
     Invoked when when operation is done successfully.
     */
    func onSuccess()

    /**
     Invoked when an error occurred while geolocation sending.
     */
    func onFailure(error: GeolocationError)
}

/**
 Provides methods to track changes of `VisitSessionState` status.
 - seealso:
 `VisitSessionState` protocol.
 */
public protocol VisitSessionStateListener: class {
    
    /**
     Called when `VisitSessionState` status is changed.
     - parameter previousState:
     Previous value of `VisitSessionState` status.
     - parameter newState:
     New value of `VisitSessionState` status.
     */
    func changed(state previousState: VisitSessionState,
                 to newState: VisitSessionState)
    
}

/**
 Delegate protocol that provides methods to handle changes of chat state.
 - seealso:
 `MessageStream.set(chatStateListener:)`
 `MessageStream.getChatState()`
 */
public protocol ChatStateListener: class {
    
    /**
     Called during `ChatState` transition.
     - parameter previousState:
     Previous state.
     - parameter newState:
     New state.
     */
    func changed(state previousState: ChatState,
                 to newState: ChatState)
    
}

/**
 - seealso:
 `MessageStream.set(currentOperatorChangeListener:)`
 `MessageStream.getCurrentOperator()`
 */
public protocol CurrentOperatorChangeListener: class {
    
    /**
     Called when `Operator` of the current chat changed.
     - parameter previousOperator:
     Previous operator.
     - parameter newOperator:
     New operator or nil if doesn't exist.
     */
    func changed(operator previousOperator: Operator?,
                 to newOperator: Operator?)
    
}

/**
 Provides methods to track changes in departments list.
 - seealso:
 `Department` protocol.
 */
public protocol DepartmentListChangeListener: class {
    
    /**
     Called when department list is received.
     - seealso:
     `Department` protocol.
     - parameter departmentList:
     Current department list.
     */
    func received(departmentList: [Department])
    
}

/**
 Interface that provides methods for handling changes in LocationSettings.
 - seealso:
 `LocationSettings`
 */
public protocol LocationSettingsChangeListener: class {
    
    /**
     Method called by an app when new LocationSettings object is received.
     - parameter previousLocationSettings:
     Previous LocationSettings state.
     - parameter newLocationSettings:
     New LocationSettings state.
     */
    func changed(locationSettings previousLocationSettings: LocationSettings,
                 to newLocationSettings: LocationSettings)
    
}

/**
 - seealso:
 `MessageStream.set(operatorTypingListener:)`
 */
public protocol OperatorTypingListener: class {
    
    /**
     Called when operator typing state changed.
     - parameter isTyping:
     True if operator is typing, false otherwise.
     */
    func onOperatorTypingStateChanged(isTyping: Bool)
    
}

/**
 Interface that provides methods for handling changes of session status.
 - seealso:
 `MessageStream.set(onlineStatusChangeListener:)`
 */
public protocol OnlineStatusChangeListener: class {
    
    /**
     Called when new session status is received.
     - parameter previousOnlineStatus:
     Previous value.
     - parameter newOnlineStatus:
     New value.
     - seealso:
     `OnlineStatus`
     */
    func changed(onlineStatus previousOnlineStatus: OnlineStatus,
                 to newOnlineStatus: OnlineStatus)
    
}

/**
Interface that provides methods for handling changes of survey.
- seealso:
`MessageStream.set(surveyListener:)`
*/
public protocol SurveyListener: class {
    
    /**
    Method to be called one time when new survey was sent by server.
    - parameter survey:
    Survey that was sent.
    */
    func on(survey: Survey)

    /**
     Method provide next question in the survey. It is called in one of two ways: survey first received or answer for previous question was successfully sent to server.
     - parameter nextQuestion:
     Next question in the survey.
     */
    func on(nextQuestion: SurveyQuestion)

    /**
     Method is called when survey timeout expires on server. It means that survey deletes and you can no longer send an answer to the question.
     */
    func onSurveyCancelled()
}

/**
 Interface that provides methods for handling changes of parameter that is to be returned by `MessageStream.getUnreadByOperatorTimestamp()` method.
 - seealso:
 `MessageStream.set(unreadByOperatorTimestampChangeListener:)`.
 */
public protocol UnreadByOperatorTimestampChangeListener: class {
    
    /**
     Method to be called when parameter that is to be returned by `MessageStream.getUnreadByOperatorTimestamp()` method is changed.
     - parameter newValue:
     New unread by operator timestamp value.
     */
    func changedUnreadByOperatorTimestampTo(newValue: Date?)
    
}

/**
 Interface that provides methods for handling changes of parameter that is to be returned by `MessageStream.getUnreadByVisitorMessageCount()` method.
 - seealso:
 `MessageStream.set(unreadByVisitorMessageCountChangeListener:)`.
 */
public protocol UnreadByVisitorMessageCountChangeListener: class {
    
    /**
     Interface that provides methods for handling changes of parameter that is to be returned by `MessageStream.getUnreadByVisitorMessageCount()` method.
     - parameter newValue:
     New unread by visitor message count value.
     */
    func changedUnreadByVisitorMessageCountTo(newValue: Int)
    
}

/**
 Interface that provides methods for handling changes of parameter that is to be returned by `MessageStream.getUnreadByVisitorTimestamp()` method.
 - seealso:
 `MessageStream.set(unreadByVisitorTimestampChangeListener:)`.
 */
public protocol UnreadByVisitorTimestampChangeListener: class {
    
    /**
     Interface that provides methods for handling changes of parameter that is to be returned by `MessageStream.getUnreadByVisitorTimestamp()` method.
     - parameter newValue:
     New unread by visitor timestamp value.
     */
    func changedUnreadByVisitorTimestampTo(newValue: Date?)
    
}

/**
 Interface that provides methods for handling Hello messages.
 - seealso:
 `MessageStream.set(helloMessageListener:)`
 - attention:
 This protocol can't be used as is. It requires that client server to support this mechanism.
 */
public protocol HelloMessageListener: class {
    
    /**
     Calls at the begining of chat when hello message is available and no messages has been sent yet.
     - parameter message:
     Text of the Hello message.
     */
    func helloMessage(message: String)
    
}

/**
 - attention:
 This protocol can't be used as is. It requires that client server to support this mechanism.
 */

public protocol ReactionCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter error:
     Error.
     - seealso:
     `ReactionError`.
     */
    func onFailure(error: ReactionError)
    
}


/**
 A chat is seen in different ways by an operator depending on ChatState.
 The initial state is `closed`.
 Then if a visitor sends a message (`MessageStream.send(message:isHintQuestion:)`), the chat changes it's state to `queue`. The chat can be turned into this state by calling `MessageStream.startChat()`.
 After that, if an operator takes the chat to process, the state changes to `chatting`. The chat is being in this state until the visitor or the operator closes it.
 When closing a chat by the visitor `MessageStream.closeChat()`, it turns into the state `closedByVisitor`, by the operator - `closedByOperator`.
 When both the visitor and the operator close the chat, it's state changes to the initial – `closed`. A chat can also automatically turn into the initial state during long-term absence of activity in it.
 Furthermore, the first message can be sent not only by a visitor but also by an operator. In this case the state will change from the initial to `invitation`, and then, after the first message of the visitor, it changes to `chatting`.
 */
public enum ChatState {
    
    /**
     Means that an operator has taken a chat for processing.
     From this state a chat can be turned into:
     * `closedByOperator`, if an operator closes the chat;
     * `closedByVisitor`, if a visitor closes the chat (`MessageStream.closeChat()`);
     * `closed`, automatically during long-term absence of activity.
     */
    case chatting
    
    @available(*, unavailable, renamed: "chatting")
    case CHATTING
    
    /**
     Means that chat is picked up by a bot.
     From this state a chat can be turned into:
     * `chatting`, if an operator intercepted the chat;
     * `closedByVisitor`, if a visitor closes the chat (`MessageStream.closeChat()`);
     * `closed`, automatically during long-term absence of activity.
     */
    case chattingWithRobot
    
    @available(*, unavailable, renamed: "chattingWithRobot")
    case CHATTING_WITH_ROBOT
    
    /**
     Means that an operator has closed the chat.
     From this state a chat can be turned into:
     * `closed`, if the chat is also closed by a visitor (`MessageStream.closeChat()`), or automatically during long-term absence of activity;
     * `queue`, if a visitor sends a new message (`MessageStream.send(message:isHintQuestion:)`).
     */
    case closedByOperator
    
    @available(*, unavailable, renamed: "closedByOperator")
    case CLOSED_BY_OPERATOR
    
    /**
     Means that a visitor has closed the chat.
     From this state a chat can be turned into:
     * `closed`, if the chat is also closed by an operator or automatically during long-term absence of activity;
     * `queue`, if a visitor sends a new message (`MessageStream.send(message:isHintQuestion:)`).
     */
    case closedByVisitor
    
    @available(*, unavailable, renamed: "closedByVisitor")
    case CLOSED_BY_VISITOR
    
    /**
     Means that a chat has been started by an operator and at this moment is waiting for a visitor's response.
     From this state a chat can be turned into:
     * `chatting`, if a visitor sends a message (`MessageStream.send(message:isHintQuestion:)`);
     * `closed`, if an operator or a visitor closes the chat (`MessageStream.closeChat()`).
     */
    case invitation
    
    @available(*, unavailable, renamed: "invitation")
    case INVITATION
    
    /**
     Means the absence of a chat as such, e.g. a chat has not been started by a visitor nor by an operator.
     From this state a chat can be turned into:
     * `queue`, if the chat is started by a visitor (by the first message or by calling `MessageStream.startChat()`;
     * `invitation`, if the chat is started by an operator.
     */
    case closed
    
    @available(*, unavailable, renamed: "closed")
    case NONE
    
    /**
     Means that a chat has been started by a visitor and at this moment is being in the queue for processing by an operator.
     From this state a chat can be turned into:
     * `chatting`, if an operator takes the chat for processing;
     * `closed`, if a visitor closes the chat (by calling (`MessageStream.closeChat()`) before it is taken for processing;
     * `closedByOperator`, if an operator closes the chat without taking it for processing.
     */
    case queue
    
    @available(*, unavailable, renamed: "queue")
    case QUEUE
    
    /**
     The state is undefined.
     This state is set as the initial when creating a new session, until the first response of the server containing the actual state is got. This state is also used as a fallback if RoxchatClientLibrary can not identify the server state (e.g. if the server has been updated to a version that contains new states).
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
}

/**
 Online state possible cases.
 - seealso:
 `OnlineStatusChangeListener`
 */
public enum OnlineStatus {
    
    /**
     Offline state with chats' count limit exceeded.
     Means that visitor is not able to send messages at all.
     */
    case busyOffline
    
    @available(*, unavailable, renamed: "busyOffline")
    case BUSY_OFFLINE
    
    /**
     Online state with chats' count limit exceeded.
     Visitor is able send offline messages, but the server can reject it.
     */
    case busyOnline
    
    @available(*, unavailable, renamed: "busyOnline")
    case BUSY_ONLINE
    
    /**
     Visitor is able to send offline messages.
     */
    case offline
    
    @available(*, unavailable, renamed: "offline")
    case OFFLINE
    
    /**
     Visitor is able to send both online and offline messages.
     */
    case online
    
    @available(*, unavailable, renamed: "online")
    case ONLINE
    
    /**
     First status is not recieved yet or status is not supported by this version of the library.
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
}

/**
 Session possible states.
 - seealso:
 `getVisitSessionState()` method of `MessageStream` protocol.
 `VisitSessionStateListener` protocol.
 */
public enum VisitSessionState {
    
    /**
     Chat in progress.
     */
    case chat
    
    @available(*, unavailable, renamed: "chat")
    case CHAT
    
    /**
     Chat must be started with department selected (there was a try to start chat without department selected).
     - seealso:
     `startChat(departmentKey:)` of `MessageStream` protocol.
     */
    case departmentSelection
    
    @available(*, unavailable, renamed: "departmentSelection")
    case DEPARTMENT_SELECTION
    
    /**
     Session is active but no chat is occuring (chat was not started yet).
     */
    case idle
    
    @available(*, unavailable, renamed: "idle")
    case IDLE
    
    /**
     Session is active but no chat is occuring (chat was closed recently).
     */
    case idleAfterChat
    
    @available(*, unavailable, renamed: "idleAfterChat")
    case IDLE_AFTER_CHAT
    
    /**
     Offline state.
     */
    case offlineMessage
    
    @available(*, unavailable, renamed: "offlineMessage")
    case OFFLINE_MESSAGE
    
    /**
     First status is not received yet or status is not supported by this version of the library.
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
}

/**
 - seealso:
 `DataMessageCompletionHandler.onFailure(messageID:error:)`.
 */
public enum DataMessageError: Error {
    
    /**
     Received error is not supported by current RoxchatClientLibrary version.
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
    // MARK: Quoted message errors
    // Note that quoted message mechanism is not a standard feature – it must be implemented by a server. For more information please contact with Roxchat support service.
    
    /**
     To be raised when quoted message ID belongs to a message without `canBeReplied` flag set to `true` (this flag is to be set on the server-side).
     */
    case quotedMessageCanNotBeReplied
    
    @available(*, unavailable, renamed: "quotedMessageCanNotBeReplied")
    case QUOTED_MESSAGE_CANNOT_BE_REPLIED
    
    /**
     To be raised when quoted message ID belongs to another visitor's chat.
     */
    case quotedMessageFromAnotherVisitor
    
    @available(*, unavailable, renamed: "quotedMessageFromAnotherVisitor")
    case QUOTED_MESSAGE_FROM_ANOTHER_VISITOR
    
    /**
     To be raised when quoted message ID belongs to multiple messages (server DB error).
     */
    case quotedMessageMultipleIds
    
    @available(*, unavailable, renamed: "quotedMessageMultipleIds")
    case QUOTED_MESSAGE_MULTIPLE_IDS
    
    /**
     To be raised when one or more required arguments of quoting mechanism are missing.
     */
    case quotedMessageRequiredArgumentsMissing
    
    @available(*, unavailable, renamed: "quotedMessageRequiredArgumentsMissing")
    case QUOTED_MESSAGE_REQUIRED_ARGUMENTS_MISSING
    
    /**
     To be raised when wrong quoted message ID is sent.
     */
    case quotedMessageWrongId
    
    @available(*, unavailable, renamed: "quotedMessageWrongId")
    case QUOTED_MESSAGE_WRONG_ID
    
}

/**
 - seealso:
 `EditMessageCompletionHandler.onFailure(messageID:error:)`
 */
public enum EditMessageError: Error {
    /**
     Received error is not supported by current RoxchatClientLibrary version.
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    /**
     Editing messages by visitor is turned off on the server.
     */
    case notAllowed
    
    @available(*, unavailable, renamed: "notAllowed")
    case NOT_ALLOWED
    /**
     Editing message is empty.
     */
    case messageEmpty
    
    @available(*, unavailable, renamed: "messageEmpty")
    case MESSAGE_EMPTY
    /**
     Visitor can edit only his messages.
     The specified id belongs to someone else's message.
     */
    case messageNotOwned
    
    @available(*, unavailable, renamed: "messageNotOwned")
    case MESSAGE_NOT_OWNED
    /**
     The server may deny a request if the message size exceeds a limit.
     The maximum size of a message is configured on the server.
     */
    case maxLengthExceeded
    
    @available(*, unavailable, renamed: "maxLengthExceeded")
    case MAX_LENGTH_EXCEEDED
    /**
     Visitor can edit only text messages.
     */
    case wrongMesageKind
    
    @available(*, unavailable, renamed: "wrongMesageKind")
    case WRONG_MESSAGE_KIND
}

/**
 - seealso:
 `DeleteMessageCompletionHandler.onFailure(messageID:error:)`
 */
public enum DeleteMessageError: Error {
    /**
     Received error is not supported by current RoxchatClientLibrary version.
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    /**
     Deleting messages by visitor is turned off on the server.
     */
    case notAllowed
    
    @available(*, unavailable, renamed: "notAllowed")
    case NOT_ALLOWED
    /**
     Visitor can delete only his messages.
     The specified id belongs to someone else's message.
     */
    case messageNotOwned
    
    @available(*, unavailable, renamed: "messageNotOwned")
    case MESSAGE_NOT_OWNED
    /**
     Message with the specified id is not found in history.
     */
    case messageNotFound
    
    @available(*, unavailable, renamed: "messageNotFound")
    case MESSAGE_NOT_FOUND
}

/**
 - seealso:
 `SendFileCompletionHandler.onFailure(messageID:error:)`
 */
public enum SendFileError: Error {
    
    /**
     The server may deny a request if the file size exceeds a limit.
     The maximum size of a file is configured on the server.
     */
    case fileSizeExceeded
    
    @available(*, unavailable, renamed: "fileSizeExceeded")
    case FILE_SIZE_EXCEEDED
    
    case fileSizeTooSmall
    
    /**
     The server may deny a request if the file type is not allowed.
     The list of allowed file types is configured on the server.
     */
    case fileTypeNotAllowed
    
    @available(*, unavailable, renamed: "fileTypeNotAllowed")
    case FILE_TYPE_NOT_ALLOWED
    
    case maxFilesCountPerChatExceeded
    
    /**
     Sending files in body is not supported. Use multipart form only.
     */
    case uploadedFileNotFound
    
    @available(*, unavailable, renamed: "uploadedFileNotFound")
    case UPLOADED_FILE_NOT_FOUND
    /**
     Received error is not supported by current RoxchatClientLibrary version.
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
    /**
    Visitor authorization error on the server.
    */
    case unauthorized
    
}

public enum SendFilesError: Error {
    case fileNotFound
    case maxFilesCountPerMessage
    case unknown
}

public enum DeleteUploadedFileError: Error {
    case fileNotFound
    case fileHasBeenSent
    case unknown
}

/**
 - seealso:
 `KeyboardResponseCompletionHandler.onFailure(error:)`.
 */
public enum KeyboardResponseError: Error {
    
    /**
     Received error is not supported by current RoxchatClientLibrary version.
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
    /**
     Arised when trying to response if no chat is exists.
     */
    case noChat
    
    @available(*, unavailable, renamed: "noChat")
    case NO_CHAT
    
    /**
     Arised when trying to response without button id.
     */
    case buttonIdNotSet
    
    @available(*, unavailable, renamed: "buttonIdNotSet")
    case BUTTON_ID_NOT_SET
    
    /**
     Arised when trying to response without request message id.
     */
    case requestMessageIdNotSet
    
    @available(*, unavailable, renamed: "requestMessageIdNotSet")
    case REQUEST_MESSAGE_ID_NOT_SET
    
    /**
     Arised when trying to response with wrong data.
     */
    case canNotCreateResponse
    
    @available(*, unavailable, renamed: "canNotCreateResponse")
    case CAN_NOT_CREATE_RESPONSE
    
}

/**
 - seealso:
 `RateOperatorCompletionHandler.onFailure(error:)`
 */
public enum RateOperatorError: Error {
    
    /**
     Arised when trying to send operator rating request if no chat is exists.
     */
    case noChat
    
    @available(*, unavailable, renamed: "noChat")
    case NO_CHAT
    
    /**
     Arised when trying to send operator rating request if passed operator ID doesn't belong to existing chat operator (or, in the same place, chat doesn't have an operator at all).
     */
    case wrongOperatorId
    
    @available(*, unavailable, renamed: "wrongOperatorId")
    case WRONG_OPERATOR_ID
    
    /**
     Note length is more than 2000 characters.
    */
    case noteIsTooLong
    
    @available(*, unavailable, renamed: "noteIsTooLong")
    case NOTE_IS_TOO_LONG

}

/**
- seealso:
`SendDialogToEmailAddressCompletionHandler.onFailure(error:)`
*/
public enum SendDialogToEmailAddressError: Error {
    /**
     There is no chat to send it to the email address.
     */
    case noChat
    
    @available(*, unavailable, renamed: "noChat")
    case NO_CHAT
    
    /**
     Exceeded sending attempts.
     */
    case sentTooManyTimes
    
    @available(*, unavailable, renamed: "sentTooManyTimes")
    case SENT_TOO_MANY_TIMES

    /**
     An unexpected error occurred while sending.
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
}

/**
- seealso:
`SendStickerCompletionHandler.onFailure(error:)`
*/
public enum SendStickerError: Error {
    /**
     There is no chat to send it to the sticker.
     */
    case noChat
    
    /**
     Not set sticker id
     */
    case noStickerId
}

/**
- seealso:
`ReactionCompletionHandler.onFailure(error:)`
*/
public enum ReactionError: Error {
    /**
     Reaction messages by visitor is turned off on the server.
     */
    case notAllowed
    
    /**
     Visitor can react only operator messages.
     */
    case messageNotOwned
    
    /**
     Message with the specified id is not found in history.
     */
    case messageNotFound
    
    /**
     Unknown error
     */
    case unknown
}

/**
- seealso:
`SendSurveyAnswerCompletionHandler.onFailure(error:)`
*/
public enum SendSurveyAnswerError {
    /**
     Incorrect value for question type 'radio'.
     */
    case incorrectRadioValue

    /**
     Incorrect value for question type 'stars'.
     */
    case incorrectStarsValue

    /**
     Incorrect survey ID.
     */
    case incorrectSurveyID

    /**
     Max comment length was exceeded for question type 'comment'.
     */
    case maxCommentLength_exceeded

    /**
     No current survey on server.
     */
    case noCurrentSurvey

    /**
     Question was not found.
     */
    case questionNotFound

    /**
     Survey is disabled on server.
     */
    case surveyDisabled

    /**
     Received error is not supported by current RoxchatClientLibrary version.
     */
    case unknown
}

/**
- seealso:
`SurveyCloseCompletionHandler.onFailure(error:)`
*/
public enum SurveyCloseError {
    /**
     Incorrect survey ID.
     */
    case incorrectSurveyID

    /**
     No current survey on server.
     */
    case noCurrentSurvey

    /**
     Survey is disabled on server.
     */
    case surveyDisabled

    /**
     Received error is not supported by current RoxchatClientLibrary version.
     */
    case unknown
}

/**
- seealso:
`GeolocationCompletionHandler.onFailure(error:)`
*/
public enum GeolocationError {
    /**
     Invalid geolocation.
     */
    case invalidGeolocation
    
    /**
     Received error is not supported by current RoxchatClientLibrary version.
     */
    case unknown
}

/**
 Item for set reaction
 - attention:
 This method can't be used as is. It requires that client server to support this mechanism.
 */
public enum ReactionString {
    /**
    Set like.
    */
    case like
    
    /**
    Set dislike.
    */
    case dislike
    
}
