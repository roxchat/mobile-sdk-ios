
import Foundation

protocol RoxchatActions {
    
    func send(message: String,
              clientSideID: String,
              dataJSONString: String?,
              isHintQuestion: Bool?,
              dataMessageCompletionHandler: DataMessageCompletionHandler?,
              editMessageCompletionHandler: EditMessageCompletionHandler?,
              sendMessageCompletionHandler: SendMessageCompletionHandler?)
    
    func send(file: Data,
              filename: String,
              mimeType: String,
              clientSideID: String,
              completionHandler: SendFileCompletionHandler?,
              uploadFileToServerCompletionHandler: UploadFileToServerCompletionHandler?)
    
    func sendFileProgress(fileSize: Int,
                          filename: String,
                          mimeType: String,
                          clientSideID: String,
                          error: SendFileError?,
                          progress: Int?,
                          state: SendFileProgressState,
                          completionHandler: SendFileCompletionHandler?,
                          uploadFileToServerCompletionHandler: UploadFileToServerCompletionHandler?)
    
    func sendFiles(message: String,
                   clientSideID: String,
                   isHintQuestion: Bool?,
                   sendFilesCompletionHandler: SendFilesCompletionHandler?)
    
    func replay(message: String,
                clientSideID: String,
                quotedMessageID: String)
    
    func delete(clientSideID: String,
                completionHandler: DeleteMessageCompletionHandler?)
    
    func deleteUploadedFile(fileGuid: String,
                            completionHandler: DeleteUploadedFileCompletionHandler?)
    
    func startChat(withClientSideID clientSideID: String,
                   firstQuestion: String?,
                   departmentKey: String?,
                   customFields: String?)
    
    func closeChat()
    
    func set(visitorTyping: Bool,
             draft: String?,
             deleteDraft: Bool)
    
    func set(prechatFields: String)
    
    func requestHistory(since: String?,
                        completion: @escaping (_ data: Data?) throws -> ())
    
    func requestHistory(beforeMessageTimestamp: Int64,
                        completion: @escaping (_ data: Data?) throws -> ())
    
    func rateOperatorWith(id: String?,
                          rating: Int,
                          visitorNote: String?,
                          completionHandler: RateOperatorCompletionHandler?)
    
    func respondSentryCall(id: String)
    
    func update(deviceToken: String)
    
    func setChatRead()
    
    func updateWidgetStatusWith(data: String)
    
    func sendKeyboardRequest(buttonId: String,
                             messageId: String,
                             completionHandler: SendKeyboardRequestCompletionHandler?)
    
    func sendDialogTo(emailAddress: String,
                      completionHandler: SendDialogToEmailAddressCompletionHandler?)
    
    func sendSticker(stickerId: Int,
                     clientSideId: String,
                     completionHandler: SendStickerCompletionHandler?)
    
    func sendReaction(reaction: ReactionString,
                     clientSideId: String,
                     completionHandler: ReactionCompletionHandler?)
    
    func sendQuestionAnswer(surveyID: String,
                            formID: Int,
                            questionID: Int,
                            surveyAnswer: String,
                            sendSurveyAnswerCompletionHandler: SendSurveyAnswerCompletionHandlerWrapper?)
    
    func closeSurvey(surveyID: String,
                     surveyCloseCompletionHandler: SurveyCloseCompletionHandler?)
    
    func getOnlineStatus(location: String,
                         completion: @escaping (_ data: Data?) throws -> ()) 
    
    func searchMessagesBy(query: String,
                          completion: @escaping (_ data: Data?) throws -> ())
    
    func clearHistory()
    
    func getServerSettings(forLocation: String,
                          completion: @escaping (_ data: Data?) throws -> ())
    
    func autocomplete(forText: String,
                      url: String,
                      completion: AutocompleteCompletionHandler?)

    func getServerSideSettings(completionHandler: ServerSideSettingsCompletionHandler?)
    
    func sendGeolocation(latitude: Double,
                         longitude: Double,
                         completionHandler: GeolocationCompletionHandler?)
}
