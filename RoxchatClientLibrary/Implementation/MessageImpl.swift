
import Foundation

/**
 Internal messages representasion.
 */
class MessageImpl {
    
    // MARK: - Properties
    private let id: String
    private let serverSideID: String?
    private let keyboard: Keyboard?
    private let keyboardRequest: KeyboardRequest?
    private let operatorID: String?
    private let quote: Quote?
    private let rawText: String?
    private let senderAvatarURLString: String?
    private let senderName: String
    private let sendStatus: MessageSendStatus
    private let serverURLString: String
    private let sticker: Sticker?
    private let text: String
    private let timeInMicrosecond: Int64
    private let type: MessageType
    private var currentChatID: String?
    private var rawData: [String: Any?]?
    private var data: MessageData?
    private var historyID: HistoryID?
    private var historyMessage: Bool
    private var read: Bool
    private var messageCanBeEdited: Bool
    private var messageCanBeReplied: Bool
    private var messageIsEdited: Bool
    private var visitorReactionInfo: String?
    private var visitorCanReact: Bool?
    private var visitorChangeReaction: Bool?
    
    // MARK: - Initialization
    init(serverURLString: String,
         id: String,
         serverSideID: String?,
         keyboard: Keyboard?,
         keyboardRequest: KeyboardRequest?,
         operatorID: String?,
         quote: Quote?,
         senderAvatarURLString: String?,
         senderName: String,
         sendStatus: MessageSendStatus = .sent,
         sticker: Sticker?,
         type: MessageType,
         rawData: [String: Any?]?,
         data: MessageData?,
         text: String,
         timeInMicrosecond: Int64,
         historyMessage: Bool,
         internalID: String?,
         rawText: String?,
         read: Bool,
         messageCanBeEdited: Bool,
         messageCanBeReplied: Bool,
         messageIsEdited: Bool,
         visitorReactionInfo: String?,
         visitorCanReact: Bool?,
         visitorChangeReaction: Bool?) {
        self.data = data
        self.id = id
        self.serverSideID = serverSideID
        self.keyboard = keyboard
        self.keyboardRequest = keyboardRequest
        self.quote = quote
        self.operatorID = operatorID
        self.rawText = rawText
        self.rawData = rawData
        self.senderAvatarURLString = senderAvatarURLString
        self.senderName = senderName
        self.sendStatus = sendStatus
        self.sticker = sticker
        self.serverURLString = serverURLString
        self.text = text
        self.timeInMicrosecond = timeInMicrosecond
        self.type = type
        self.read = read
        self.messageCanBeEdited = messageCanBeEdited
        self.messageCanBeReplied = messageCanBeReplied
        self.messageIsEdited = messageIsEdited
        self.visitorReactionInfo = visitorReactionInfo
        self.visitorCanReact = visitorCanReact
        self.visitorChangeReaction = visitorChangeReaction
        
        self.historyMessage = historyMessage
        if historyMessage {
            guard let internalID = internalID else {
                RoxchatInternalLogger.shared.log(entry: "Message has not Internal ID in MessageImpl.\(#function)")
                fatalError("Message has not Internal ID in MessageImpl.\(#function)")
            }
            historyID = HistoryID(dbID: internalID,
                                  timeInMicrosecond: timeInMicrosecond)
        }
        currentChatID = internalID
    }
    
    func disableBotButtons() -> Bool {
        if self.type == .keyboard {
            if let keyboard = self.keyboard as? KeyboardImpl {
                if keyboard.getState() == .pending {
                    keyboard.keyboardItem.state = .canceled
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Methods
    func getRawText() -> String? {
        return rawText
    }
    
    func getSenderAvatarURLString() -> String? {
        return senderAvatarURLString
    }
    
    func getTimeInMicrosecond() -> Int64 {
        return timeInMicrosecond
    }
    
    func hasHistoryComponent() -> Bool {
        return (historyID != nil)
    }
    
    func getHistoryID() -> HistoryID? {
        guard let historyID = historyID else {
            RoxchatInternalLogger.shared.log(
                entry: "Message \(self.toString()) do not have history component.",
                verbosityLevel: .debug,
                logType: .messageHistory)
            
            return nil
        }
        
        return historyID
    }
    
    func getServerUrlString() -> String {
        return serverURLString
    }
    
    func getSource() -> MessageSource {
        return (historyMessage ? MessageSource.history : MessageSource.currentChat)
    }
    
    func transferToCurrentChat(message: MessageImpl) -> MessageImpl {
        if self != message {
            message.setSecondaryHistory(historyEquivalentMessage: self)
            
            return message
        }
        
        setSecondaryCurrentChat(currentChatEquivalentMessage: message)
        
        invertHistoryStatus()
        
        return self
    }
    
    func transferToHistory(message: MessageImpl) -> MessageImpl {
        if self != message {
            message.setSecondaryCurrentChat(currentChatEquivalentMessage: self)
            
            return message
        }
        
        setSecondaryHistory(historyEquivalentMessage: message)
        
        invertHistoryStatus()
        
        return self
    }
    
    func invertHistoryStatus() {
        guard historyID != nil,
            currentChatID != nil else {
                RoxchatInternalLogger.shared.log(
                    entry: "Message \(self.toString()) has not history component or does not belong to current chat.",
                    verbosityLevel: .debug,
                    logType: .messageHistory)
                
                return
        }
        
        historyMessage = !historyMessage
    }
    
    func setSecondaryHistory(historyEquivalentMessage: MessageImpl) {
        guard !getSource().isHistoryMessage(),
            historyEquivalentMessage.getSource().isHistoryMessage() else {
                RoxchatInternalLogger.shared.log(
                    entry: "Message \(self.toString()) is already has history component.",
                    verbosityLevel: .debug,
                    logType: .messageHistory)
                
                return
        }
        
        historyID = historyEquivalentMessage.getHistoryID()
    }
    
    func setSecondaryCurrentChat(currentChatEquivalentMessage: MessageImpl) {
        guard getSource().isHistoryMessage(),
            !currentChatEquivalentMessage.getSource().isHistoryMessage() else {
                RoxchatInternalLogger.shared.log(entry: "Current chat equivalent of the message \(self.toString()) is already has history component.",
                    verbosityLevel: .debug)
                
                return
        }
        
        currentChatID = currentChatEquivalentMessage.getCurrentChatID()
    }
    
    func setRead(isRead: Bool) {
        read = isRead
    }
    
    func getRead() -> Bool {
        return read
    }
    
    func setMessageCanBeEdited(messageCanBeEdited: Bool) {
        self.messageCanBeEdited = messageCanBeEdited
    }
    
    func toString() -> String {
        return """
MessageImpl {
    serverURLString = \(serverURLString),
    ID = \(id),
    operatorID = \(operatorID ?? "nil"),
    senderAvatarURLString = \(senderAvatarURLString ?? "nil"),
    senderName = \(senderName),
    type = \(type),
    text = \(text),
    timeInMicrosecond = \(timeInMicrosecond),
    attachment = \(data?.getAttachment()?.getFileInfo().getURL()?.absoluteString ?? "nil"),
    historyMessage = \(historyMessage),
    currentChatID = \(currentChatID ?? "nil"),
    historyID = \(historyID?.getDBid() ?? "nil"),
    rawText = \(rawText ?? "nil"),
    read = \(read)
}
"""
    }
    
    // MARK: -
    enum MessageSource {
        case history
        case currentChat
        
        // MARK: - Methods
        
        func assertIsCurrentChat() throws {
            guard isCurrentChatMessage() else {
                throw MessageError.invalidState("Current message is not a part of current chat.")
            }
        }
        
        func assertIsHistory() throws {
            guard isHistoryMessage() else {
                throw MessageError.invalidState("Current message is not a part of the history.")
            }
        }
        
        func isHistoryMessage() -> Bool {
            return (self == .history)
        }
        
        func isCurrentChatMessage() -> Bool {
            return (self == .currentChat)
        }
        
    }
    
    // MARK: -
    enum MessageError: Error {
        case invalidState(String)
    }
    
}

extension MessageImpl: Message {
    func getQuote() -> Quote? {
        return quote
    }
    
    func getRawData() -> [String : Any?]? {
        return rawData
    }
    
    func getData() -> MessageData? {
        return data
    }
    
    func getID() -> String {
        return id
    }
    
    func getServerSideID() -> String? {
        return serverSideID
    }
    
    func getCurrentChatID() -> String? {
        guard let currentChatID = currentChatID else {
            RoxchatInternalLogger.shared.log(entry: "Message \(self.toString()) do not have an ID in current chat or do not exist in current chat or chat exists itself not.",
                verbosityLevel: .debug)
            
            return nil
        }
        
        return currentChatID
    }
    
    func getKeyboard() -> Keyboard? {
        return keyboard
    }
    
    func getKeyboardRequest() -> KeyboardRequest? {
        return keyboardRequest
    }
    
    func getOperatorID() -> String? {
        return operatorID
    }
    
    func getSenderAvatarFullURL() -> URL? {
        guard let senderAvatarURLString = senderAvatarURLString else {
            return nil
        }
        
        return URL(string: (serverURLString + senderAvatarURLString))
    }
    
    func getSendStatus() -> MessageSendStatus {
        return sendStatus
    }
    
    func getSenderName() -> String {
        return senderName
    }
    
    func getSticker() -> Sticker? {
        return sticker
    }
    
    func getText() -> String {
        return text
    }
    
    func getTime() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timeInMicrosecond / 1_000_000))
    }
    
    func getType() -> MessageType {
        return type
    }
    
    func isEqual(to message: Message) -> Bool {
        guard let message = message as? MessageImpl else {
            return false
        }
        return (self == message)
    }
    
    func isReadByOperator() -> Bool {
        return getRead() //todo: maybe returns old value
    }
    
    func canBeEdited() -> Bool {
        return messageCanBeEdited
    }
    
    func canBeReplied() -> Bool {
        return messageCanBeReplied
    }
    
    func isEdited() -> Bool {
        return messageIsEdited
    }
    
    func getVisitorReaction() -> String? {
        return visitorReactionInfo
    }
    
    func canVisitorReact() -> Bool {
        return visitorCanReact ?? false
    }

    func canVisitorChangeReaction() -> Bool {
        return visitorChangeReaction ?? false
    }
    
}

extension MessageImpl: Equatable {
    
    static func == (lhs: MessageImpl,
                    rhs: MessageImpl) -> Bool {
        return ((((((((lhs.id == rhs.id)
            && (lhs.operatorID == rhs.operatorID))
            && (lhs.rawText == rhs.rawText))
            && (lhs.senderAvatarURLString == rhs.senderAvatarURLString))
            && (lhs.senderName == rhs.senderName))
            && (lhs.text == rhs.text))
            && (lhs.timeInMicrosecond == rhs.timeInMicrosecond))
            && (lhs.type == rhs.type))
            && (lhs.isReadByOperator() == rhs.isReadByOperator()
            && (lhs.canBeEdited() == rhs.canBeEdited()
            && (lhs.isEdited() == rhs.isEdited())))
    }
    
}

/**
 Internal messages' data representation.
 */
final class MessageDataImpl: MessageData {
    
    // MARK: - Properties
    private let attachment: MessageAttachment?
    
    // MARK: - Initialization
    init(attachment: MessageAttachment?) {
        self.attachment = attachment
    }
    
    // MARK: - Methods
    func getAttachment() -> MessageAttachment? {
        return attachment
    }
    
}

/**
 Internal messages' attachments representation.
 */
final class MessageAttachmentImpl: MessageAttachment {
    
    // MARK: - Properties
    private let fileInfo: FileInfo
    private let filesInfo: [FileInfo]
    private let state: AttachmentState
    private var downloadProgress: Int64?
    private var errorType: String?
    private var errorMessage: String?
    
    // MARK: - Initialization
    init(fileInfo: FileInfo,
         filesInfo: [FileInfo],
         state: AttachmentState,
         downloadProgress: Int64? = nil,
         errorType: String? = nil,
         errorMessage: String? = nil) {
        self.fileInfo = fileInfo
        self.filesInfo = filesInfo
        self.state = state
        self.downloadProgress = downloadProgress
        self.errorType = errorType
        self.errorMessage = errorMessage
    }
    
    // MARK: - Methods
    func getFileInfo() -> FileInfo {
        return fileInfo
    }
    
    
    func getFilesInfo() -> [FileInfo] {
        return filesInfo
    }
    
    func getState() -> AttachmentState {
        return state
    }
    
    func getDownloadProgress() -> Int64? {
        return downloadProgress
    }
    
    func getErrorType() -> String? {
        return errorType
    }
    
    func getErrorMessage() -> String? {
        return errorMessage
    }
    
}

/**
 Internal fileinfo representation.
 */
final class FileInfoImpl {
    
    // MARK: - Constants
    private enum Period: Int64 {
        case attachmentURLExpires = 300 // (seconds) = 5 (minutes).
    }
    
    
    // MARK: - Properties
    private let urlString: String?
    private let size: Int64?
    private let filename: String
    private let contentType: String?
    private let imageInfo: ImageInfo?
    private let guid: String?
    private weak var fileUrlCreator: FileUrlCreator?
    
    
    // MARK: - Initialization
    init(urlString: String?,
         size: Int64?,
         filename: String,
         contentType: String?,
         imageInfo: ImageInfo? = nil,
         guid: String?,
         fileUrlCreator: FileUrlCreator?) {
        self.urlString = urlString
        self.size = size
        self.filename = filename
        self.contentType = contentType
        self.imageInfo = imageInfo
        self.guid = guid
        self.fileUrlCreator = fileUrlCreator
    }
    
    // MARK: - Methods
    static func getAttachment(byFileUrlCreator fileUrlCreator: FileUrlCreator,
                              text: String) -> FileInfoImpl? {
        guard let textData = text.data(using: .utf8) else {
            RoxchatInternalLogger.shared.log(entry: "Convert Text to Data failure in MessageImpl.\(#function)")
            return nil
        }
        
        guard let optionaltextDictionary = (
            (try? JSONSerialization.jsonObject(with: textData, options: [])
                as? [String: Any?])
                as [String : Any?]??),
            let textDictionary = optionaltextDictionary else {
            RoxchatInternalLogger.shared.log(
                entry: "Message attachment parameters parsing failed: \(text).",
                verbosityLevel: .warning
            )
            return nil
        }
        
        return getAttachment(byFileUrlCreator: fileUrlCreator,
                             textDictionary: textDictionary)
    }
    
    static func getAttachments(byFileUrlCreator fileUrlCreator: FileUrlCreator,
                               text: String) -> [FileInfoImpl] {
        var attachments = [FileInfoImpl]()
        guard let textData = text.data(using: .utf8) else {
            RoxchatInternalLogger.shared.log(entry: "Convert Text to Data failure in MessageImpl.\(#function)")
            return []
        }
        guard let optionaltextDictionaryArray = (
            (try? JSONSerialization.jsonObject(with: textData, options: [])
                as? [Any])
                as [Any]??),
            let textDictionaryArray = optionaltextDictionaryArray else {
            return []
        }
        for textDictionary in textDictionaryArray {
            if let textDictionary = textDictionary as? [String: Any?],
               let fileInfoImpl = getAttachment(byFileUrlCreator: fileUrlCreator,
                                                textDictionary: textDictionary) {
                attachments.append(fileInfoImpl)
            }
        }
        return attachments
    }
    
    // MARK: Private methods
    private static func getAttachment(byFileUrlCreator fileUrlCreator: FileUrlCreator,
                                      textDictionary: [String: Any?]) -> FileInfoImpl? {
        let fileParameters = FileParametersItem(jsonDictionary: textDictionary)
        guard let filename = fileParameters.getFilename(),
            let guid = fileParameters.getGUID(),
            let contentType = fileParameters.getContentType() else {
            return nil
        }
        
        let fileURLString = fileUrlCreator.createFileURL(byFilename: filename, guid: guid, isThumb: true)
            
        return FileInfoImpl(urlString: fileURLString,
                            size: fileParameters.getSize(),
                            filename: filename,
                            contentType: contentType,
                            imageInfo: extractImageInfoOf(fileParameters: fileParameters,
                                                          fileUrlCreator: fileUrlCreator),
                            guid: guid,
                            fileUrlCreator: fileUrlCreator)
    }
    
    private static func extractImageInfoOf(fileParameters: FileParametersItem?,
                                           fileUrlCreator: FileUrlCreator) -> ImageInfo? {
        guard let fileParameters = fileParameters,
              let filename = fileParameters.getFilename(),
              let guid = fileParameters.getGUID(),
              let thumbURLString = fileUrlCreator.createFileURL(byFilename: filename, guid: guid, isThumb: true),
            let imageSize = fileParameters.getImageParameters()?.getSize() else {
            return nil
        }
        
        return ImageInfoImpl(withThumbURLString: thumbURLString,
                             fileUrlCreator: fileUrlCreator,
                             filename: filename,
                             guid: guid,
                             width: imageSize.getWidth(),
                             height: imageSize.getHeight())
    }
    
}

extension FileInfoImpl: FileInfo {
    
    func getContentType() -> String? {
        return contentType
    }
    
    func getFileName() -> String {
        return filename
    }
    
    func getImageInfo() -> ImageInfo? {
        return imageInfo
    }
    
    func getSize() -> Int64? {
        return size
    }
    
    func getGuid() -> String? {
        return guid
    }
    
    func getURL() -> URL? {
        guard let urlString = self.urlString else {
            RoxchatInternalLogger.shared.log(entry: "Getting URL from String failure because URL String is nil in MessageImpl.\(#function)")
            return nil
        }
        if let guid = guid,
           let currentURLString = fileUrlCreator?.createFileURL(byFilename: filename, guid: guid) {
            return URL(string: currentURLString)
        }
        return URL(string: urlString)
    }
    
}

/**
 Internal image information representation.
 - seealso:
 `MessageAttachment`
 */
final class ImageInfoImpl: ImageInfo {
    
    // MARK: - Properties
    private let thumbURLString: String
    private let width: Int?
    private let height: Int?
    private weak var fileUrlCreator: FileUrlCreator?
    private let filename: String
    private let guid: String?
    
    // MARK: - Initialization
    init(withThumbURLString thumbURLString: String,
         fileUrlCreator: FileUrlCreator?,
         filename: String,
         guid: String?,
         width: Int?,
         height: Int?) {
        self.thumbURLString = thumbURLString
        self.fileUrlCreator = fileUrlCreator
        self.filename = filename
        self.guid = guid
        self.width = width
        self.height = height
    }
    
    // MARK: - Methods
    // MARK: ImageInfo protocol methods
    
    func getThumbURL() -> URL {
        guard let guid = guid,
              let currentURLString = fileUrlCreator?.createFileURL(byFilename: filename, guid: guid, isThumb: true),
              let thumbURL = URL(string: currentURLString) else {
            RoxchatInternalLogger.shared.log(entry: "Getting Thumb URL from String failure in MessageImpl.\(#function)")
            fatalError("Getting Thumb URL from String failure in MessageImpl.\(#function)")
        }
        return thumbURL
    }
    
    func getHeight() -> Int? {
        return height
    }
    
    func getWidth() -> Int? {
        return width
    }
    
}

/**
 - seealso:
 `Keyboard`
 */
final class KeyboardImpl: Keyboard {
    
    fileprivate var keyboardItem: KeyboardItem
    
    init?(data: [String: Any?]) {
        if let keyboard = KeyboardItem(jsonDictionary: data) {
            self.keyboardItem = keyboard
        } else {
            return nil
        }
    }
    
    static func getKeyboard(jsonDictionary: [String : Any?]) -> Keyboard? {
        return KeyboardImpl(data: jsonDictionary)
    }
    
    func getButtons() -> [[KeyboardButton]] {
        var buttonArrayArray = [[KeyboardButton]]()
        for buttonArray in keyboardItem.getButtons() {
            var newButtonArray = [KeyboardButton]()
            for button in buttonArray {
                guard let buttonImpl = KeyboardButtonImpl(data: button) else {
                    RoxchatInternalLogger.shared.log(entry: "Getting KeyboardButtonImpl from data failure in KeyboardImpl.\(#function)")
                    return []
                }
                newButtonArray.append(buttonImpl)
            }
            buttonArrayArray.append(newButtonArray)
        }
        return buttonArrayArray
    }
    
    func getState() -> KeyboardState {
        return keyboardItem.getState()
    }
    
    func getResponse() -> KeyboardResponse? {
        return KeyboardResponseImpl(data: keyboardItem.getResponse())
    }
}

/**
 - seealso:
 `Sticker`
 */
final class StickerImpl: Sticker {
    private let stickerItem: StickerItem
    
    init?(data: [String: Any?]) {
        if let sticker = StickerItem(jsonDictionary: data) {
            self.stickerItem = sticker
        } else {
            return nil
        }
    }
    
    init(stickerId: Int) {
        self.stickerItem = StickerItem(stickerId: stickerId)
    }
    
    static func getSticker(jsonDictionary: [String : Any?]) -> Sticker? {
        return StickerImpl(data: jsonDictionary)
    }
    
    func getStickerId() -> Int {
        return stickerItem.getStickerId()
    }
}

/**
 - seealso:
 `KeyboardButton`
 */
final class KeyboardButtonImpl: KeyboardButton {
    
    private let buttonItem: KeyboardButtonItem
    
    init?(data: KeyboardButtonItem?) {
        if let buttonItem = data {
            self.buttonItem = buttonItem
        } else {
            return nil
        }
    }
    
    func getID() -> String {
        return buttonItem.getId()
    }
    
    func getText() -> String {
        return buttonItem.getText()
    }
    
    func getConfiguration() -> Configuration? {
        return ConfigurationImpl(data: buttonItem.getConfiguration())
    }
}

/**
 - seealso:
 `KeyboardResponse`
 */
final class KeyboardResponseImpl: KeyboardResponse {
    
    private let keyboardResponseItem: KeyboardResponseItem
    
    init?(data: KeyboardResponseItem?) {
        if let keyboardResponse = data {
            self.keyboardResponseItem = keyboardResponse
        } else {
            return nil
        }
    }
    
    func getButtonID() -> String {
        return keyboardResponseItem.getButtonId()
    }
    
    func getMessageID() -> String {
        return keyboardResponseItem.getMessageId()
    }
}

/**
 - seealso:
 `KeyboardResponse`
 */
final class KeyboardRequestImpl: KeyboardRequest {
    
    private let keyboardRequestItem: KeyboardRequestItem
    
    init?(data: [String: Any?]) {
        if let keyboardRequest = KeyboardRequestItem(jsonDictionary: data) {
            self.keyboardRequestItem = keyboardRequest
        } else {
            return nil
        }
    }
    
    static func getKeyboardRequest(jsonDictionary: [String : Any?]) -> KeyboardRequest? {
        return KeyboardRequestImpl(data: jsonDictionary)
    }
    
    func getButton() -> KeyboardButton {
        guard let buttonImpl = KeyboardButtonImpl(data: keyboardRequestItem.getButton()) else {
            RoxchatInternalLogger.shared.log(entry: "Getting KeyboardButtonImpl from data failure in KeyboardRequestImpl.\(#function)")
            fatalError("Getting KeyboardButtonImpl from data failure in KeyboardRequestImpl.\(#function)")
        }
        return buttonImpl
    }
    
    func getMessageID() -> String {
        return keyboardRequestItem.getMessageId()
    }
}

/**
 - seealso:
 `KeyboardButton`
 */
final class ConfigurationImpl: Configuration {
    
    private let configurationItem: ConfigurationItem
    
    init?(data: ConfigurationItem?) {
        if let configurationItem = data {
            self.configurationItem = configurationItem
        } else {
            return nil
        }
    }
    
    func isActive() -> Bool {
        return configurationItem.isActive()
    }
    
    func getButtonType() -> ButtonType {
        return configurationItem.getButtonType()
    }
    
    func getData() -> String {
        return configurationItem.getData()
    }
    
    func getState() -> ButtonState {
        return configurationItem.getState()
    }
 
}


/**
 - seealso:
 `Message.getQuote()`
 */
final class QuoteImpl: Quote {
    
    private let state: QuoteState
    private let authorID: String?
    private let messageAttachment: FileInfo?
    private let messageID: String?
    private let messageType: MessageType?
    private let senderName: String?
    private let text: String?
    private let rawText: String?
    private let timestamp: Int64?
    
    init(state: QuoteState,
         authorID: String?,
         messageAttachment: FileInfo?,
         messageID: String?,
         messageType: MessageType?,
         senderName: String?,
         text: String?,
         rawText: String?,
         timestamp: Int64?) {
        self.state = state
        self.authorID = authorID
        self.messageAttachment = messageAttachment
        self.messageID = messageID
        self.messageType = messageType
        self.senderName = senderName
        self.text = text
        self.rawText = rawText
        self.timestamp = timestamp
    }
    
    // MARK: - Methods
    static func getQuote(quoteItem: QuoteItem?, messageAttachment: FileInfo?, fileUrlCreator: FileUrlCreator? = nil) -> Quote? {
        guard let quoteItem = quoteItem else {
            return nil
        }
        var text = quoteItem.getText()
        let rawText = quoteItem.getText()
        var messageType: MessageType? = nil
        if let messageKind = quoteItem.getMessageKind() {
            messageType = MessageMapper.convert(messageKind: messageKind)
        }
        var quoteMessageAttachment = messageAttachment
        if let messageAttachment = messageAttachment {
            text = messageAttachment.getFileName()
        } else if messageType == .fileFromOperator || messageType == .fileFromVisitor,
           let fileUrlCreator = fileUrlCreator,
           let rawText = text {
            quoteMessageAttachment = FileInfoImpl.getAttachment(byFileUrlCreator: fileUrlCreator, text: rawText)
            if let quoteMessageAttachment = quoteMessageAttachment {
                text = quoteMessageAttachment.getFileName()
            }
        }
        guard let quoteState = quoteItem.getState() else {
            RoxchatInternalLogger.shared.log(entry: "Quote Item has not State in KeyboardRequestImpl.\(#function)")
            return nil
        }
        
        return QuoteImpl(state: convert(quoteState: quoteState),
                         authorID: quoteItem.getAuthorID(),
                         messageAttachment: quoteMessageAttachment,
                         messageID: quoteItem.getID(),
                         messageType: messageType,
                         senderName: quoteItem.getSenderName(),
                         text: text,
                         rawText: rawText,
                         timestamp: quoteItem.getTimeInMicrosecond())
    }
    
    func getRawText() -> String? {
        return rawText
    }
    
    func getAuthorID() -> String? {
        return authorID
    }
    
    func getMessageAttachment() -> FileInfo? {
        return messageAttachment
    }
    
    func getMessageTimestamp() -> Date? {
        guard let timestamp = timestamp else {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(timestamp / 1_000_000))
        
    }
    
    func getMessageID() -> String? {
        return messageID
    }
    
    func getMessageText() -> String? {
        return text
    }
    
    func getMessageType() -> MessageType? {
        return messageType
    }
    
    func getSenderName() -> String? {
        return senderName
    }
    
    func getState() -> QuoteState {
        return state
    }
    
    static private func convert(quoteState: QuoteItem.QuoteStateItem) -> QuoteState {
        switch quoteState {
        case .pending:
            return .pending
        case .filled:
            return .filled
        case .notFound:
            return .notFound
        }
    }
}
