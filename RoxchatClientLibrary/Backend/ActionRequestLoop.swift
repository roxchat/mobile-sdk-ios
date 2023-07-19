
import Foundation

/**
 Class that handles HTTP-requests sended by RoxchatClientLibrary with visitor requested actions (e.g. sending messages, operator rating, chat closing etc.).
 */
class ActionRequestLoop: AbstractRequestLoop {
    
    // MARK: - Properties
    var actionOperationQueue: OperationQueue?
    var historyRequestOperationQueue: OperationQueue?
    @WMSynchronized var authorizationData: AuthorizationData?
    
    
    // MARK: - Initialization
    init(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor,
         internalErrorListener: InternalErrorListener, notFatalErrorHandler: NotFatalErrorHandler?) {
        super.init(completionHandlerExecutor: completionHandlerExecutor, internalErrorListener: internalErrorListener)
    }
    
    init(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor,
         internalErrorListener: InternalErrorListener) {
        super.init(completionHandlerExecutor: completionHandlerExecutor, internalErrorListener: internalErrorListener)
    }
    
    // MARK: - Methods
    
    override func start() {
        guard actionOperationQueue == nil && historyRequestOperationQueue == nil else {
            return
        }
        
        actionOperationQueue = OperationQueue()
        actionOperationQueue?.maxConcurrentOperationCount = 1
        actionOperationQueue?.qualityOfService = .userInitiated
        
        historyRequestOperationQueue = OperationQueue()
        historyRequestOperationQueue?.maxConcurrentOperationCount = 1
        historyRequestOperationQueue?.qualityOfService = .userInitiated
    }
    
    override func stop() {
        super.stop()
        
        actionOperationQueue?.cancelAllOperations()
        actionOperationQueue = nil
        
        historyRequestOperationQueue?.cancelAllOperations()
        historyRequestOperationQueue = nil
    }
    
    func set(authorizationData: AuthorizationData?) {
        self.authorizationData = authorizationData
    }
    
    func enqueue(request: RoxchatRequest, withAuthData: Bool = true) {
        let operationQueue = request.getCompletionHandler() != nil ? historyRequestOperationQueue : actionOperationQueue
        operationQueue?.addOperation { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let urlRequest = self.createUrlRequest(request: request, withAuthData: withAuthData)
            
            do {
                guard let urlRequest = urlRequest else {
                    RoxchatInternalLogger.shared.log(
                        entry: "Unwrapping url request failure in ActionRequestLoop.\(#function)",
                        logType: .networkRequest)
                    return
                }
                let data = try self.perform(request: urlRequest)
                if let dataJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    if let error = dataJSON[AbstractRequestLoop.ResponseFields.error.rawValue] as? String {
                        if error == RoxchatInternalError.reinitializationRequired.rawValue {
                            do {
                                try self.authorizationData = self.awaitForNewAuthorizationData(withLastAuthorizationData: nil)
                            } catch {
                                return
                            }
                            self.enqueue(request: request)
                        } else {
                            self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                                self.parseRoxchatRequestJsonError(error, request: request)
                            })
                        }
                        return
                    }
                    self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                        self.parseRoxchatRequest(request: request, data: data, dataJSON: dataJSON)
                    })
                } else if let _ = try? JSONSerialization.jsonObject(with: self.prepareServerSideData(rawData: data),options: []) as? [String : Any] {
                    self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                        self.executeServerSideSettingsRequest(request: request, data: data)
                    })
                } else {
                    RoxchatInternalLogger.shared.log(
                        entry: "Error de-serializing server response: \(String(data: data, encoding: .utf8) ?? "unreadable data")",
                        verbosityLevel: .warning,
                        logType: .networkRequest)
                }
            } catch let sendFileError as SendFileError {
                // SendFileErrors are generated from HTTP code.
                if let sendFileCompletionHandler = request.getSendFileCompletionHandler() {
                    guard let messageID = request.getMessageID() else {
                        RoxchatInternalLogger.shared.log(
                            entry: "Request has not message ID in ActionRequestLoop.\(#function)",
                            logType: .networkRequest)
                        return
                    }
                    self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                        sendFileCompletionHandler.onFailure(messageID: messageID,
                                                            error: sendFileError)
                    })
                    
                }
            } catch let unknownError as UnknownError {
                self.handleRequestLoop(error: unknownError)
            } catch {
                RoxchatInternalLogger.shared.log(
                    entry: "Request failed with unknown error: \(request.getBaseURLString()).",
                    verbosityLevel: .warning,
                    logType: .networkRequest)
            }
        }
    }
    
    private func createUrlRequest(request: RoxchatRequest, withAuthData: Bool) -> URLRequest? {
        if self.authorizationData == nil {
            do {
                try self.authorizationData = self.awaitForNewAuthorizationData(withLastAuthorizationData: nil) // wtf
            } catch {
                return nil
            }
        }
        
        guard let usedAuthorizationData = self.authorizationData else {
            RoxchatInternalLogger.shared.log(
                entry: "Authorization Data is nil in ActionRequestLoop.\(#function)")
            return nil
        }
        
        if !self.isRunning() {
            return nil
        }
        
        var parameterDictionary = request.getPrimaryData()
        if withAuthData {
            parameterDictionary[Parameter.pageID.rawValue] = usedAuthorizationData.getPageID()
            parameterDictionary[Parameter.authorizationToken.rawValue] = usedAuthorizationData.getAuthorizationToken()
        }
        let parametersString = parameterDictionary.stringFromHTTPParameters()
        
        var urlRequest: URLRequest?
        let httpMethod = request.getHTTPMethod()
        if httpMethod == .get {
            guard let url = URL(string: (request.getBaseURLString() + "?" + parametersString)) else {
                RoxchatInternalLogger.shared.log(entry: "Invalid URL in ActionRequestLoop.\(#function)")
                return nil
            }
            urlRequest = URLRequest(url: url)
        } else { // POST
            if let fileName = request.getFileName(),
                let mimeType = request.getMimeType(),
                let fileData = request.getFileData(),
                let boundaryString = request.getBoundaryString() {
                // Assuming that ready HTTP body is passed only for multipart requests.
                guard let url = URL(string: (request.getBaseURLString())) else {
                    RoxchatInternalLogger.shared.log(entry: "Invalid URL in ActionRequestLoop.\(#function)")
                    return nil
                }
                urlRequest = URLRequest(url: url)
                urlRequest?.httpBody = self.createHTTPBody(
                    filename: fileName,
                    mimeType: mimeType,
                    fileData: fileData,
                    boundaryString: boundaryString,
                    primaryData: parameterDictionary
                )
            } else {
                // For URL encoded requests.
                guard let url = URL(string: (request.getBaseURLString())) else {
                    RoxchatInternalLogger.shared.log(entry: "Invalid URL in ActionRequestLoop.\(#function)")
                    return nil
                }
                urlRequest = URLRequest(url: url)
                urlRequest?.httpBody = parametersString.data(using: .utf8)
            }
            
            // Assuming that content type field is always exists when it is POST request, and does not when request is of GET type.
            urlRequest?.setValue(request.getContentType(),
                                 forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest?.httpMethod = httpMethod.rawValue
        return urlRequest
        
    }
    
    private func parseRoxchatRequestJsonError(_ error: String, request: RoxchatRequest) {
        
        switch error {
        case RoxchatInternalError.reinitializationRequired.rawValue:
            break
        case RoxchatInternalError.fileSizeExceeded.rawValue,
             RoxchatInternalError.fileTypeNotAllowed.rawValue,
             RoxchatInternalError.uploadedFileNotFound.rawValue,
             RoxchatInternalError.notAllowedMimeType.rawValue,
             RoxchatInternalError.notMatchingMagicNumbers.rawValue,
             RoxchatInternalError.unauthorized.rawValue,
             RoxchatInternalError.maxFilesCountPerChatExceeded.rawValue,
             RoxchatInternalError.fileSizeTooSmall.rawValue:
            self.handleSendFile(error: error,
                                ofRequest: request)
            RoxchatInternalAlert.shared.present(title: .visitorActionError, message: .fileSendingError)
            
            break
        case RoxchatInternalError.fileNotFound.rawValue,
             RoxchatInternalError.fileHasBeenSent.rawValue:
            self.handleDeleteUploadedFile(error: error,
                                  ofRequest: request)
            RoxchatInternalAlert.shared.present(title: .visitorActionError, message: .fileDeletingError)
            
            break
        case RoxchatInternalError.wrongArgumentValue.rawValue:
            self.handleWrongArgumentValueError(ofRequest: request)
            
            break
        case RoxchatInternalError.noChat.rawValue,
             RoxchatInternalError.operatorNotInChat.rawValue:
            self.handleRateOperator(error: error,
                                    ofRequest: request)
            RoxchatInternalAlert.shared.present(title: .visitorActionError, message: .operatorRatingError)
            
            break
        case RoxchatInternalError.messageNotFound.rawValue,
             RoxchatInternalError.notAllowed.rawValue,
             RoxchatInternalError.messageNotOwned.rawValue:
            self.handleDeleteMessage(error: error,
                                    ofRequest: request)
            self.handleReactionError(error: error,
                                    ofRequest: request)
            
            break
        case RoxchatInternalError.buttonIdNotSet.rawValue,
             RoxchatInternalError.requestMessageIdNotSet.rawValue,
             RoxchatInternalError.canNotCreateResponse.rawValue,
             RoxchatInternalError.canNotCreateResponseOld.rawValue:
            self.handleKeyboardResponse(error: error,
                                        ofRequest: request)
            break
        case RoxchatInternalError.sentTooManyTimes.rawValue:
            self.handleSendDialogResponse(error: error,
                                          ofRequest: request)
            
            break
        case RoxchatInternalError.surveyDisabled.rawValue,
             RoxchatInternalError.noCurrentSurvey.rawValue,
             RoxchatInternalError.incorrectSurveyID.rawValue,
             RoxchatInternalError.incorrectStarsValue.rawValue,
             RoxchatInternalError.maxCommentLenghtExceeded.rawValue,
             RoxchatInternalError.incorrectRadioValue.rawValue,
             RoxchatInternalError.questionNotFound.rawValue:
            self.handleSendSurveyAnswer(error: error,
                                        ofRequest: request)
            self.handleSurveyClose(error: error,
                                   ofRequest: request)
            
            break
        case RoxchatInternalError.noStickerId.rawValue:
            self.handleSendStickerError(error: error,
                                        ofRequest: request)
    
        case RoxchatInternalError.accountBlocked.rawValue,
             RoxchatInternalError.visitorBanned.rawValue,
             RoxchatInternalError.providedVisitorFieldsExpired.rawValue,
             RoxchatInternalError.wrongProvidedVisitorFieldsHashValue.rawValue:
             self.internalErrorListener?.on(error: error)
             self.internalErrorListener?.connectionStateChanged(connected: false)
            RoxchatInternalAlert.shared.present(title: .accountError, message: .accountConnectionError)
             break
        case RoxchatInternalError.invalidCoordinatesReceived.rawValue:
            self.handleGeolocationCompletionHandler(error: error, ofRequest: request)
        default:

            break
        }
    }
    
    private func parseRoxchatRequest(request: RoxchatRequest, data: Data, dataJSON: [String: Any]) {
        // Some internal errors can be received inside "error" field inside "data" field.
        if let dataDictionary = dataJSON[AbstractRequestLoop.ResponseFields.data.rawValue] as? [String: Any],
            let errorString = dataDictionary[AbstractRequestLoop.DataFields.error.rawValue] as? String {
            self.handleDataMessage(error: errorString,
                                   ofRequest: request)
        }
        
        if let completionHandler = request.getSearchMessagesCompletionHandler() {
            self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                do {
                    try completionHandler(data)
                } catch {
                    RoxchatInternalLogger.shared.log(
                        entry: "Error executing search messages callback on receiver data: \(String(data: data, encoding: .utf8) ?? "unreadable data").",
                        verbosityLevel: .warning,
                        logType: .networkRequest)
                }
            })
        }

        if let completionHandler = request.getCompletionHandler() {
            self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                do {
                    try completionHandler(data)
                } catch {
                    RoxchatInternalLogger.shared.log(
                        entry: "Error executing callback on receiver data: \(String(data: data, encoding: .utf8) ?? "unreadable data").",
                        verbosityLevel: .warning,
                        logType: .networkRequest)
                }
                
            })
        }
        
        if let completionHandler = request.getLocationSettingsRequestCompletionHandler() {
            self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                do {
                    try completionHandler(data)
                } catch {
                    RoxchatInternalLogger.shared.log(
                        entry: "Error executing callback on receiver data: \(String(data: data, encoding: .utf8) ?? "unreadable data").",
                        verbosityLevel: .warning,
                        logType: .networkRequest)
                }
                
            })
        }

        if let completionHandler = request.getLocationStatusCompletionHandler() {
            self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                do {
                    try completionHandler(data)
                } catch {
                    RoxchatInternalLogger.shared.log(
                        entry: "Error executing callback on receiver data: \(String(data: data, encoding: .utf8) ?? "unreadable data").",
                        verbosityLevel: .warning,
                        logType: .networkRequest)
                }
                
            })
        }
        
        if let completionHandler = request.getAutocompleteCompletionHandler() {
            if let suggestions = dataJSON["suggestions"] as? [[String: Any?]] {
                var suggestuionTexts = [String]()
                for suggestion in suggestions {
                    if let text = suggestion["text"] as? String {
                        suggestuionTexts.append(text)
                    }
                }
                completionHandler.onSuccess(text: suggestuionTexts)
            } else {
                completionHandler.onFailure(error: .hintApiInvalid)
            }
        }
        
        self.handleClientCompletionHandlerOf(request: request, dataJSON: dataJSON[AbstractRequestLoop.ResponseFields.data.rawValue] as? [String : Any?])
    }

    private func executeServerSideSettingsRequest(request: RoxchatRequest,
                                                  data: Data) {
        if let completionHandler = request.getServerSideCompletionHandler() {
            self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                do {
                    let roxchatServerSideSettings = try self.decodeToServerSideSettings(data: data)
                    completionHandler.onSuccess(roxchatServerSideSettings: roxchatServerSideSettings)
                } catch {
                    completionHandler.onFailure()
                    RoxchatInternalLogger.shared.log(
                        entry: "Error executing callback on receiver data: \(String(data: data, encoding: .utf8) ?? "unreadable data").",
                        verbosityLevel: .warning,
                        logType: .networkRequest)
                }
            })
        }
    }

    
    // MARK: Private methods
    
    private func createHTTPBody(filename: String,
                                mimeType: String,
                                fileData: Data,
                                boundaryString: String,
                                primaryData: [String: Any]) -> Data {
        
        let boundaryStart = "--\(boundaryString)\r\n"
        let contentDispositionString = "Content-Disposition: form-data; name=\"roxchat_upload_file\"; filename=\"\(filename)\"\r\n"
        let contentTypeString = "Content-Type: \(mimeType)\r\n\r\n"
        let boundaryEnd = "--\(boundaryString)--\r\n"
        
        var requestBodyData = Data()
        for (key, value) in primaryData {
            guard let boundaryData = "--\(boundaryString)\r\n".data(using: .utf8),
            let keyData = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8),
            let valueData = "\(value)\r\n".data(using: .utf8) else {
                RoxchatInternalLogger.shared.log(entry: "Data configuration failure in ActionRequestLoop.\(#function)")
                return requestBodyData
            }
            requestBodyData.append(boundaryData)
            requestBodyData.append(keyData)
            requestBodyData.append(valueData)
        }
        guard let boundaryStartData = boundaryStart.data(using: .utf8),
            let contentDispositionStringData = contentDispositionString.data(using: .utf8),
            let contentTypeStringData = contentTypeString.data(using: .utf8),
            let lineBreakData = "\r\n".data(using: .utf8),
            let boundaryEndData = boundaryEnd.data(using: .utf8) else {
            RoxchatInternalLogger.shared.log(entry: "Data configuration failure in ActionRequestLoop.\(#function)")
            return requestBodyData
            
        }
        requestBodyData.append(boundaryStartData)
        requestBodyData.append(contentDispositionStringData)
        requestBodyData.append(contentTypeStringData)
        requestBodyData.append(fileData)
        requestBodyData.append(lineBreakData)
        requestBodyData.append(boundaryEndData)
        
        return requestBodyData
    }
    
    private func awaitForNewAuthorizationData(withLastAuthorizationData lastAuthorizationData: AuthorizationData?) throws -> AuthorizationData {
        while isRunning()
                && (lastAuthorizationData == self.authorizationData) {
                usleep(100_000) // 0.1 s.
        }
        
        guard let authorizationData = self.authorizationData else {
            // Interrupted request.
            throw AbstractRequestLoop.UnknownError.interrupted
        }
        
        return authorizationData
    }
    
    private func handleDataMessage(error errorString: String,
                                   ofRequest roxchatRequest: RoxchatRequest) {
        if let dataMessageCompletionHandler = roxchatRequest.getDataMessageCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                guard let messageID = roxchatRequest.getMessageID() else {
                    RoxchatInternalLogger.shared.log(
                        entry: "Roxchat Request has not message ID in ActionRequestLoop.\(#function)",
                        logType: .networkRequest)
                    return
                }
                dataMessageCompletionHandler.onFailure(messageID: messageID,
                                                       error: ActionRequestLoop.convertToPublic(dataMessageErrorString: errorString))
            })
        }
    }
    
    private func handleRateOperator(error errorString: String,
                                    ofRequest roxchatRequest: RoxchatRequest) {
        if let rateOperatorCompletionhandler = roxchatRequest.getRateOperatorCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let rateOperatorError: RateOperatorError
                switch errorString {
                case RoxchatInternalError.noChat.rawValue:
                    rateOperatorError = .noChat
                case RoxchatInternalError.noteIsTooLong.rawValue:
                    rateOperatorError = .noteIsTooLong
                default:
                    rateOperatorError = .wrongOperatorId
                }
                
                rateOperatorCompletionhandler.onFailure(error: rateOperatorError)
            })
        }
    }
    
    private func handleEditMessage(error errorString: String,
                                   ofRequest roxchatRequest: RoxchatRequest) {
        if let editMessageCompletionHandler = roxchatRequest.getEditMessageCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let editMessageError: EditMessageError
                switch errorString {
                case RoxchatInternalError.messageEmpty.rawValue:
                    editMessageError = .messageEmpty
                    break
                case RoxchatInternalError.maxMessageLengthExceeded.rawValue:
                    editMessageError = .maxLengthExceeded
                    break
                case RoxchatInternalError.notAllowed.rawValue:
                    editMessageError = .notAllowed
                    break
                case RoxchatInternalError.messageNotOwned.rawValue:
                    editMessageError = .messageNotOwned
                    break
                case RoxchatInternalError.wrongMessageKind.rawValue:
                    editMessageError = .wrongMesageKind
                    break
                default:
                    editMessageError = .unknown
                }
                
                guard let messageID = roxchatRequest.getMessageID() else {
                    RoxchatInternalLogger.shared.log(
                        entry: "Roxchat Request has not message ID in ActionRequestLoop.\(#function)",
                        logType: .networkRequest)
                    return
                }
                editMessageCompletionHandler.onFailure(messageID: messageID,
                                                       error: editMessageError)
            })
        }
    }
    
    private func handleDeleteMessage(error errorString: String,
                                    ofRequest roxchatRequest: RoxchatRequest) {
        if let deleteMessageCompletionHandler = roxchatRequest.getDeleteMessageCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let deleteMessageError: DeleteMessageError
                switch errorString {
                case RoxchatInternalError.messageNotFound.rawValue:
                    deleteMessageError = .messageNotFound
                    break
                case RoxchatInternalError.notAllowed.rawValue:
                    deleteMessageError = .notAllowed
                    break
                case RoxchatInternalError.messageNotOwned.rawValue:
                    deleteMessageError = .messageNotOwned
                    break
                default:
                    deleteMessageError = .unknown
                }
                
                guard let messageID = roxchatRequest.getMessageID() else {
                    RoxchatInternalLogger.shared.log(
                        entry: "Roxchat Request has not message ID in ActionRequestLoop.\(#function)",
                        logType: .networkRequest)
                    return
                }
                deleteMessageCompletionHandler.onFailure(messageID: messageID,
                                                         error: deleteMessageError)
            })
        }
    }
    
    private func handleSendFile(error errorString: String,
                                ofRequest roxchatRequest: RoxchatRequest) {
        let sendFileCompletionHandler = roxchatRequest.getSendFileCompletionHandler()
        let uploadFileToServerCompletionHandler = roxchatRequest.getUploadFileToServerCompletionHandler()
        completionHandlerExecutor?.execute(task: DispatchWorkItem {
            let sendFileError: SendFileError
            switch errorString {
            case RoxchatInternalError.fileSizeExceeded.rawValue:
                sendFileError = .fileSizeExceeded
                break
            case RoxchatInternalError.fileSizeTooSmall.rawValue:
                sendFileError = .fileSizeTooSmall
                break
            case RoxchatInternalError.fileTypeNotAllowed.rawValue:
                sendFileError = .fileTypeNotAllowed
                break
            case RoxchatInternalError.uploadedFileNotFound.rawValue:
                sendFileError = .uploadedFileNotFound
                break
            case RoxchatInternalError.unauthorized.rawValue:
                sendFileError = .unauthorized
                break
            default:
                sendFileError = .unknown
            }
                
            guard let messageID = roxchatRequest.getMessageID() else {
                RoxchatInternalLogger.shared.log(
                    entry: "Roxchat Request has not message ID in ActionRequestLoop.\(#function)",
                    logType: .networkRequest)
                return
            }
            sendFileCompletionHandler?.onFailure(messageID: messageID,
                                                 error: sendFileError)
            uploadFileToServerCompletionHandler?.onFailure(messageID: messageID, error: sendFileError)
        })
    }
    
    private func handleDeleteUploadedFile(error errorString: String,
                                  ofRequest roxchatRequest: RoxchatRequest) {
        if let deleteUploadedFileCompletionHandler = roxchatRequest.getDeleteUploadedFileCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let deleteUploadedFileError: DeleteUploadedFileError
                switch errorString {
                case RoxchatInternalError.fileNotFound.rawValue:
                    deleteUploadedFileError = .fileNotFound
                    break
                case RoxchatInternalError.fileHasBeenSent.rawValue:
                    deleteUploadedFileError = .fileHasBeenSent
                    break
                default:
                    deleteUploadedFileError = .unknown
                }
                deleteUploadedFileCompletionHandler.onFailure(error: deleteUploadedFileError)
            })
        }
    }
    
    private func handleSendStickerError(error errorString: String,
                                        ofRequest roxchatRequest: RoxchatRequest) {
        if let sendStickerCompletionHandler = roxchatRequest.getSendStickerCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let sendStickerError: SendStickerError
                switch errorString {
                case RoxchatInternalError.noStickerId.rawValue:
                    sendStickerError = .noStickerId
                default:
                    sendStickerError = .noChat
                }
                sendStickerCompletionHandler.onFailure(error: sendStickerError)
            })
        }
    }
    
    private func handleReactionError(error errorString: String,
                                     ofRequest roxchatRequest: RoxchatRequest) {
        if let reactionCompletionHandler = roxchatRequest.getReactionCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let reactionError: ReactionError
                switch errorString {
                case RoxchatInternalError.messageNotFound.rawValue:
                    reactionError = .messageNotFound
                    break
                case RoxchatInternalError.notAllowed.rawValue:
                    reactionError = .notAllowed
                    break
                case RoxchatInternalError.messageNotOwned.rawValue:
                    reactionError = .messageNotOwned
                    break
                default:
                    reactionError = .unknown
                }
                reactionCompletionHandler.onFailure(error: reactionError)
            })
        }
    }
    
    private func handleKeyboardResponse(error errorString: String,
                                        ofRequest roxchatRequest: RoxchatRequest) {
        if let keyboardResponseCompletionHandler = roxchatRequest.getKeyboardResponseCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let keyboardResponseError: KeyboardResponseError
                switch errorString {
                case RoxchatInternalError.buttonIdNotSet.rawValue:
                    keyboardResponseError = .buttonIdNotSet
                    break
                case RoxchatInternalError.requestMessageIdNotSet.rawValue:
                    keyboardResponseError = .requestMessageIdNotSet
                    break
                case RoxchatInternalError.canNotCreateResponse.rawValue:
                    keyboardResponseError = .canNotCreateResponse
                    break
                default:
                    keyboardResponseError = .unknown
                }
                
                guard let messageID = roxchatRequest.getMessageID() else {
                    RoxchatInternalLogger.shared.log(
                        entry: "Roxchat Request has not message ID in ActionRequestLoop.\(#function)",
                        logType: .networkRequest)
                    return
                }
                keyboardResponseCompletionHandler.onFailure(messageID: messageID, error: keyboardResponseError)
            })
        }
    }
    
    private func handleSendDialogResponse(error errorString: String,
                                          ofRequest roxchatRequest: RoxchatRequest) {
        if let sendDialogResponseCompletionHandler = roxchatRequest.getSendDialogToEmailAddressCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let sendDialogResponseError: SendDialogToEmailAddressError
                switch errorString {
                case RoxchatInternalError.sentTooManyTimes.rawValue:
                    sendDialogResponseError = .sentTooManyTimes
                    break
                case RoxchatInternalError.noChat.rawValue:
                    sendDialogResponseError = .noChat
                    break
                default:
                    sendDialogResponseError = .unknown
                }
                
                sendDialogResponseCompletionHandler.onFailure(error: sendDialogResponseError)
            })
        }
    }
    
    private func handleSendSurveyAnswer(error errorString: String,
                                        ofRequest roxchatRequest: RoxchatRequest) {
        if let sendSurveyAnswerCompletionHandler = roxchatRequest.getSendSurveyAnswerCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let sendSurveyAnswerError: SendSurveyAnswerError
                switch errorString {
                case RoxchatInternalError.surveyDisabled.rawValue:
                    sendSurveyAnswerError = .surveyDisabled
                    break
                case RoxchatInternalError.noCurrentSurvey.rawValue:
                    sendSurveyAnswerError = .noCurrentSurvey
                    break
                case RoxchatInternalError.incorrectSurveyID.rawValue:
                    sendSurveyAnswerError = .incorrectSurveyID
                    break
                case RoxchatInternalError.incorrectStarsValue.rawValue:
                    sendSurveyAnswerError = .incorrectStarsValue
                    break
                case RoxchatInternalError.maxCommentLenghtExceeded.rawValue:
                    sendSurveyAnswerError = .maxCommentLength_exceeded
                    break
                case RoxchatInternalError.questionNotFound.rawValue:
                    sendSurveyAnswerError = .questionNotFound
                    break
                default:
                    sendSurveyAnswerError = .unknown
                }
                
                sendSurveyAnswerCompletionHandler.onFailure(error: sendSurveyAnswerError)
            })
        }
    }
    
    private func handleSurveyClose(error errorString: String,
                                    ofRequest roxchatRequest: RoxchatRequest) {
        if let surveyCloseCompletionHandler = roxchatRequest.getSurveyCloseCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let surveyCloseError: SurveyCloseError
                switch errorString {
                case RoxchatInternalError.surveyDisabled.rawValue:
                    surveyCloseError = .surveyDisabled
                    break
                case RoxchatInternalError.noCurrentSurvey.rawValue:
                    surveyCloseError = .noCurrentSurvey
                    break
                case RoxchatInternalError.incorrectSurveyID.rawValue:
                    surveyCloseError = .incorrectSurveyID
                    break
                default:
                    surveyCloseError = .unknown
                }
                
                surveyCloseCompletionHandler.onFailure(error: surveyCloseError)
            })
        }
    }
    
    private func handleGeolocationCompletionHandler(error errorString: String,
                                                    ofRequest roxchatRequest: RoxchatRequest) {
        if let geolocationCompletionHandler = roxchatRequest.getGeolocationCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let geolocationError: GeolocationError
                switch errorString {
                case RoxchatInternalError.invalidCoordinatesReceived.rawValue:
                    geolocationError = .invalidGeolocation
                    break
                default:
                    geolocationError = .unknown
                }
                
                geolocationCompletionHandler.onFailure(error: geolocationError)
            })
        }
    }
    
    private func handleWrongArgumentValueError(ofRequest roxchatRequest: RoxchatRequest) {
        RoxchatInternalLogger.shared.log(
            entry: "Request \(roxchatRequest.getBaseURLString()) with parameters \(roxchatRequest.getPrimaryData().stringFromHTTPParameters()) failed with error \(RoxchatInternalError.wrongArgumentValue.rawValue)",
            verbosityLevel: .warning,
            logType: .networkRequest)
    }
    
    private func handleClientCompletionHandlerOf(request: RoxchatRequest, dataJSON: [String: Any?]?) {
        completionHandlerExecutor?.execute(task: DispatchWorkItem {
            request.getSendDialogToEmailAddressCompletionHandler()?.onSuccess()
            request.getSendSurveyAnswerCompletionHandler()?.onSuccess()
            request.getSurveyCloseCompletionHandler()?.onSuccess()
            request.getRateOperatorCompletionHandler()?.onSuccess()
            request.getSendStickerCompletionHandler()?.onSuccess()
            request.getDeleteUploadedFileCompletionHandler()?.onSuccess()
            request.getGeolocationCompletionHandler()?.onSuccess()
            
            if let messageID = request.getMessageID() {
                request.getDataMessageCompletionHandler()?.onSuccess(messageID: messageID)
                request.getSendFileCompletionHandler()?.onSuccess(messageID: messageID)
                request.getDeleteMessageCompletionHandler()?.onSuccess(messageID: messageID)
                request.getEditMessageCompletionHandler()?.onSuccess(messageID: messageID)
                request.getReactionCompletionHandler()?.onSuccess(messageID: messageID)
                request.getKeyboardResponseCompletionHandler()?.onSuccess(messageID: messageID)
                request.getSendFilesCompletionHandler()?.onSuccess(messageID: messageID)
                if let dataJSON = dataJSON {
                    request.getUploadFileToServerCompletionHandler()?.onSuccess(id: messageID, uploadedFile: self.getUploadedFileFrom(dataJSON: dataJSON))
                }
            } else {
                RoxchatInternalLogger.shared.log(
                    entry: "Request has not message ID in ActionRequestLoop.\(#function)",
                    logType: .networkRequest)
            }
        })
    }
    
    private func getUploadedFileFrom(dataJSON: [String: Any?]) -> UploadedFile {
        let fileParameters = FileParametersItem(jsonDictionary: dataJSON)
        return UploadedFileImpl(size: fileParameters.getSize() ?? 0,
                                guid: fileParameters.getGUID() ?? "",
                                contentType: fileParameters.getContentType(),
                                filename: fileParameters.getFilename() ?? "",
                                visitorID: fileParameters.getVisitorID() ?? "",
                                clientContentType: fileParameters.getClientContentType() ?? "",
                                imageParameters: fileParameters.getImageParameters())
    }
    
    private static func convertToPublic(dataMessageErrorString: String) -> DataMessageError {
        switch dataMessageErrorString {
        case RoxchatInternalError.quotedMessageCannotBeReplied.rawValue:
            return .quotedMessageCanNotBeReplied
        case RoxchatInternalError.quotedMessageCorruptedID.rawValue:
            return .quotedMessageWrongId
        case RoxchatInternalError.quotedMessageFromAnotherVisitor.rawValue:
            return .quotedMessageFromAnotherVisitor
        case RoxchatInternalError.quotedMessageMultipleID.rawValue:
            return .quotedMessageMultipleIds
        case RoxchatInternalError.quotedMessageNotFound.rawValue:
            return .quotedMessageWrongId
        case RoxchatInternalError.quotedMessageRequiredArgumentsMissing.rawValue:
            return .quotedMessageRequiredArgumentsMissing
        default:
            return .unknown
        }
    }
    
}
