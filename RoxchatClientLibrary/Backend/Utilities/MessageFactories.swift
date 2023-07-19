
import Foundation

/**
 Abstract class that supposed to be parent of mapper classes that are responsible for converting internal message model objects to public one.
 */
class MessageMapper {
    
    // MARK: - Constants
    private enum MapError: Error {
        case invalidMessageType(String)
    }
    
    // MARK: - Properties
    private let serverURLString: String
    private var fileUrlCreator: FileUrlCreator?
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    // MARK: - Methods
    
    static func convert(messageKind: MessageItem.MessageKind) -> MessageType? {
        switch messageKind {
        case .actionRequest:
            return .actionRequest
        case .contactInformationRequest:
            return .contactInformationRequest
        case .fileFromOperator:
            return .fileFromOperator
        case .fileFromVisitor:
            return .fileFromVisitor
        case .info:
            return .info
        case .keyboard:
            return .keyboard
        case .keyboardResponse:
            return .keyboardResponse
        case .operatorMessage:
            return .operatorMessage
        case .operatorBusy:
            return .operatorBusy
        case .visitorMessage:
            return .visitorMessage
        case .stickerVisitor:
            return .stickerVisitor
        default:
            RoxchatInternalLogger.shared.log(entry: "Invalid message type received: \(messageKind.rawValue)",
                verbosityLevel: .warning)

            return nil
        }
    }
    
    func convert(messageItem: MessageItem,
                 historyMessage: Bool) -> MessageImpl? {
        guard let kind = messageItem.getKind() else {
            return nil
        }
        if kind == .contactInformation || kind == .forOperator {
            return nil
        }
        guard let type = MessageMapper.convert(messageKind: kind) else {
            return nil
        }
        
        var attachment: FileInfoImpl?
        var attachments: [FileInfoImpl]
        var keyboard: Keyboard?
        var keyboardRequest: KeyboardRequest?
        var text: String?
        var rawText: String?
        var data: MessageData?
        var sticker: Sticker?
        
        guard let messageItemText = messageItem.getText() else {
            RoxchatInternalLogger.shared.log(entry: "Message Item Text is nil in MessageFactories.\(#function)")
            return nil
        }
        if (kind == .fileFromVisitor)
            || (kind == .fileFromOperator) {
            
            if let fileUrlCreator = fileUrlCreator {
                attachments = FileInfoImpl.getAttachments(byFileUrlCreator: fileUrlCreator,
                                                          text: messageItemText)
                if attachments.isEmpty {
                    attachment = FileInfoImpl.getAttachment(byFileUrlCreator: fileUrlCreator,
                                                            text: messageItemText)
                    if let attachment = attachment {
                        attachments.append(attachment)
                    }
                } else {
                    attachment = attachments.first
                }
                if let attachment = attachment {
                    var file: FileItem?
                    if let rawData = messageItem.getRawData() {
                        file = MessageDataItem(jsonDictionary: rawData).getFile()
                    }
                    let state: AttachmentState
                    switch file?.getState() {
                    case .error:
                        state = .error
                        break
                    case .externalChecks:
                        state = .externalChecks
                        break
                    default:
                        state = .ready
                    }
                    data = MessageDataImpl(
                        attachment: MessageAttachmentImpl(fileInfo: attachment,
                                                          filesInfo: attachments,
                                                          state: state,
                                                          errorType: file?.getErrorType(),
                                                          errorMessage: file?.getErrorMessage())
                    )
                } else {
                    if let rawData = messageItem.getRawData(),
                       let file = MessageDataItem(jsonDictionary: rawData).getFile() {
                        let state: AttachmentState
                        switch file.getState() {
                        case .error:
                            state = .error
                            break
                        case .externalChecks:
                            state = .externalChecks
                            break
                        default:
                            state = .ready
                        }
                        let fileInfoImpl = FileInfoImpl(urlString: nil,
                                                        size: file.getProperties()?.getSize() ?? 0,
                                                        filename: file.getProperties()?.getFilename() ?? "",
                                                        contentType: file.getProperties()?.getContentType() ?? "",
                                                        guid: file.getProperties()?.getGUID() ?? "",
                                                        fileUrlCreator: nil)
                        attachment = fileInfoImpl
                        attachments.append(fileInfoImpl)
                        data = MessageDataImpl(
                            attachment: MessageAttachmentImpl(fileInfo: fileInfoImpl,
                                                              filesInfo: attachments,
                                                              state: state,
                                                              downloadProgress: file.getDownloadProgress(),
                                                              errorType: file.getErrorType(),
                                                              errorMessage: file.getErrorMessage()))
                    }
                }
            }
            guard let attachment = attachment else {
                return nil
            }
            
            text = attachment.getFileName()
            rawText = messageItemText
        } else {
            text = messageItemText
        }
        
        if kind == .keyboard, let data = messageItem.getRawData() {
            keyboard = KeyboardImpl.getKeyboard(jsonDictionary: data)
        }
        
        if kind == .keyboardResponse, let data = messageItem.getRawData() {
            keyboardRequest = KeyboardRequestImpl.getKeyboardRequest(jsonDictionary: data)
        }
        
        if kind == .stickerVisitor, let data = messageItem.getRawData() {
            sticker = StickerImpl.getSticker(jsonDictionary: data)
        }
        
        let quote = messageItem.getQuote()
        var messageAttachmentFromQuote: FileInfo? = nil
        if let kind = quote?.getMessageKind(), kind == .fileFromVisitor || kind == .fileFromOperator {
            if let fileUrlCreator = fileUrlCreator {
                guard let quoteText = quote?.getText() else {
                    RoxchatInternalLogger.shared.log(entry: "Quote Text is nil in MessageFactories.\(#function)")
                    return nil
                }
                messageAttachmentFromQuote = FileInfoImpl.getAttachment(byFileUrlCreator: fileUrlCreator,
                                                                        text: quoteText)
                if messageAttachmentFromQuote == nil {
                    let attachments = FileInfoImpl.getAttachments(byFileUrlCreator: fileUrlCreator,
                                                                  text: quoteText)
                    if !attachments.isEmpty {
                        messageAttachmentFromQuote = attachments[0]
                    }
                }
            }
        }
        
        
        guard let clientSideID = messageItem.getClientSideID() else {
            RoxchatInternalLogger.shared.log(entry: "Message Item has not Client Side ID in MessageFactories.\(#function)")
            return nil
        }
        guard let senderName = messageItem.getSenderName() else {
            RoxchatInternalLogger.shared.log(entry: "Message Item has not Sender Name in MessageFactories.\(#function)")
            return nil
        }
        guard let messageText = text else {
            RoxchatInternalLogger.shared.log(entry: "Message has not Text in MessageFactories.\(#function)")
            return nil
        }
        guard let timeInMicrosecond = messageItem.getTimeInMicrosecond() else {
            RoxchatInternalLogger.shared.log(entry: "Message Item has not Time In Microsecond in MessageFactories.\(#function)")
            return nil
        }
        
        return MessageImpl(serverURLString: serverURLString,
                           clientSideID: clientSideID,
                           serverSideID: messageItem.getServerSideID(),
                           keyboard: keyboard,
                           keyboardRequest: keyboardRequest,
                           operatorID: messageItem.getSenderID(),
                           quote: QuoteImpl.getQuote(quoteItem: quote, messageAttachment: messageAttachmentFromQuote),
                           senderAvatarURLString: messageItem.getSenderAvatarURLString(),
                           senderName: senderName,
                           sticker: sticker,
                           type: type,
                           rawData: messageItem.getRawData(),
                           data: data,
                           text: messageText,
                           timeInMicrosecond: timeInMicrosecond,
                           historyMessage: historyMessage,
                           internalID: messageItem.getServerSideID(),
                           rawText: rawText,
                           read: messageItem.getRead() ?? true,
                           messageCanBeEdited: messageItem.getCanBeEdited(),
                           messageCanBeReplied: messageItem.getCanBeReplied(),
                           messageIsEdited: messageItem.getIsEdited(),
                           visitorReactionInfo: messageItem.getReaction(),
                           visitorCanReact: messageItem.getCanVisitorReact(),
                           visitorChangeReaction: messageItem.getCanVisitorChangeReaction())
    }
    
    func set(fileUrlCreator: FileUrlCreator) {
        self.fileUrlCreator = fileUrlCreator
    }
    
    func mapAll(messages: [MessageItem]) -> [MessageImpl] {
        return messages.map { map(message: $0) }.compactMap { $0 }
    }
    
    func map(message: MessageItem) -> MessageImpl? {
        preconditionFailure("This method must be overridden!")
    }
    
}

/**
 Concrete mapper class that is responsible for converting internal message model objects to public message model objects of current chat.
 */
final class CurrentChatMessageMapper: MessageMapper {
    
    // MARK: - Methods
    override func map(message: MessageItem) -> MessageImpl? {
        return convert(messageItem: message,
                       historyMessage: false)
    }
    
}

/**
 Concrete mapper class that is responsible for converting internal message model objects to public message model objects of previous chats.
 */
final class HistoryMessageMapper: MessageMapper {
    
    // MARK: - Methods
    override func map(message: MessageItem) -> MessageImpl? {
        return convert(messageItem: message,
                       historyMessage: true)
    }
    
}

/**
 Class that responsible for creating child class objects for public message model objects of messages that are to be sent by visitor.
 */
final class SendingFactory {
    
    // MARK: - Properties
    var serverURLString: String
    
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    
    // MARK: - Methods
    
    func createTextMessageToSendWith(id: String,
                                     text: String) -> MessageToSend {
        return MessageToSend(serverURLString: serverURLString,
                             clientSideID: id,
                             senderName: "",
                             type: .visitorMessage,
                             text: text,
                             timeInMicrosecond: InternalUtils.getCurrentTimeInMicrosecond())
    }
    
    func createTextMessageToSendWithQuoteWith(id: String,
                                              text: String,
                                              repliedMessage: Message) -> MessageToSend {
        return MessageToSend(serverURLString: serverURLString,
                             clientSideID: id,
                             senderName: "",
                             type: .visitorMessage,
                             text: text,
                             timeInMicrosecond: InternalUtils.getCurrentTimeInMicrosecond(),
                             quote: QuoteImpl(state: QuoteState.pending,
                                              authorID: nil,
                                              messageAttachment: repliedMessage.getData()?.getAttachment()?.getFileInfo(),
                                              messageID: repliedMessage.getCurrentChatID(),
                                              messageType: repliedMessage.getType(),
                                              senderName: repliedMessage.getSenderName(),
                                              text: repliedMessage.getText(),
                                              rawText: repliedMessage.getText(),
                                              timestamp: Int64(repliedMessage.getTime().timeIntervalSince1970 * 1000)))
    }

    
    func createFileMessageToSendWith(id: String, data: MessageData? = nil) -> MessageToSend {
        return MessageToSend(serverURLString: serverURLString,
                             clientSideID: id,
                             senderName: "",
                             type: .fileFromVisitor,
                             text: "",
                             timeInMicrosecond: InternalUtils.getCurrentTimeInMicrosecond(),
                             data: data)
    }
    
    func createStickerMessageToSendWith(id: String, stickerId: Int) -> MessageToSend {
        return MessageToSend(serverURLString: serverURLString,
                             clientSideID: id,
                             senderName: "",
                             type: .stickerVisitor,
                             text: "",
                             timeInMicrosecond: InternalUtils.getCurrentTimeInMicrosecond(),
                             sticker: StickerImpl(stickerId: stickerId))
    }
    
}
