

import Foundation


/**
 Abstracts a single message in the message history.
 A message is an immutable object. It means that changing some of the message fields creates a new object. Messages can be compared by using `isEqual(to:)` method for searching messages with the same set of fields or by ID (`message1.getID() == message2.getID()`) for searching logically identical messages. ID is formed on the client side when sending a message (`MessageStream.send(message:isHintQuestion:)` or `MessageStream.sendFile(atPath:mimeType:completion:)).
 */
public protocol Message {
    
    /**
     Messages of type `MessageType.actionRequest` contain custom dictionary.
     - returns:
     Dictionary which contains custom fields or `nil` if there's no such custom fields.
     */
    func getRawData() -> [String: Any?]?
    
    /**
    Messages of types `MessageType.FILE_FROM_OPERATOR` and `MessageType.FILE_FROM_VISITOR` can contain file.
    - returns:
    The file of the message.
    */
    func getData() -> MessageData?
    
    /**
     Every message can be uniquefied by its ID. Messages also can be lined up by its IDs.
     - important:
     ID doesn’t change while changing the content of a message.
     - returns:
     Unique ID of the message.
     */
    func getID() -> String
    
    /**
     Every message can be uniquefied by its server ID. Messages also can be lined up by its IDs.
     - important:
     ID doesn’t change while changing the content of a message.
     - returns:
     Unique server ID of the message.
     */
    func getServerSideID() -> String?
    
    
    /**
     Current chat id of the message.
     - important:
     ID doesn’t change while changing the content of a message.
     - returns:
     Unique ID of the message.
     */
    func getCurrentChatID() -> String?
    
    /**
     Messages of type `MessageType.keyboard` contain keyboard from script bot.
     - returns:
     Keyboard with buttons.
     */
    func getKeyboard() -> Keyboard?
    
    /**
     Messages of type `MessageType.keyboardResponse` contain keyboard request from script bot.
     - returns:
     Keyboard request.
     */
    func getKeyboardRequest() -> KeyboardRequest?
    
    /**
     - returns:
     ID of a message sender, if the sender is an operator.
     */
    func getOperatorID() -> String?
    
    
    /**
     - returns:
     Quote message.
     */
    func getQuote() -> Quote?
    
    /**
     - returns:
     The sticker item that was sent to the server.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     */
    func getSticker() -> Sticker?
    
    /**
     - returns:
     URL of a sender's avatar or `nil` if one does not exist.
     */
    func getSenderAvatarFullURL() -> URL?
    
    /**
     - returns:
     Name of a message sender.
     */
    func getSenderName() -> String
    
    /**
     - returns:
     `MessageSendStatus.sent` if a message had been sent to the server, was received by the server and was delivered to all the clients; `MessageSendStatus.sending` if not.
     */
    func getSendStatus() -> MessageSendStatus
    
    /**
     - returns:
     Text of the message.
     */
    func getText() -> String
    
    /**
     - returns:
     Timestamp of the moment the message was processed by the server.
     */
    func getTime() -> Date
    
    /**
     - seealso:
     `MessageType` enum.
     - returns:
     Type of a message.
     */
    func getType() -> MessageType
    
    /**
     Method which can be used to compare if two Message objects have identical contents.
     - parameter message:
     Second `Message` object.
     - returns:
     True if two `Message` objects are identical and false otherwise.
     */
    func isEqual(to message: Message) -> Bool
    
    /**
     - returns:
     True if visitor message read by operator or this message is not by visitor and false otherwise.
     */
    func isReadByOperator() -> Bool
    
    /**
     - returns:
     True if this message can be edited or deleted.
     */
    func canBeEdited() -> Bool
    
    /**
     - returns:
     True if this message can be replied.
     */
    func canBeReplied() -> Bool
    
    /**
     - returns:
     True if this message is edited.
     */
    func isEdited() -> Bool
    
    
    /**
     - returns:
     True if this message can be reacted.
     */
    func canVisitorReact() -> Bool
    
    /**
     - returns:
     Visitor reaction.
     */
    func getVisitorReaction() -> String?
    
    /**
     - returns:
     True if visitor can change react.
     */
    func canVisitorChangeReaction() -> Bool
}

/**
Contains a file attached to the message.
- seealso:
`Message.getData()`
*/
public protocol MessageData {
    
    /**
     Messages of the types `MessageType.FILE_FROM_OPERATOR` and `MessageType.FILE_FROM_VISITOR` can contain attachments.
     - important:
     Notice that this method may return nil even in the case of previously listed types of messages. E.g. if a file is being sent.
     - seealso:
     `MessageAttachment` protocol.
     - returns:
     Information about the file that is attached to the message.
     */
    func getAttachment() -> MessageAttachment?
    
}

/**
 Contains an attachment file.
 - seealso:
 `MessageData.getAttachment()`
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 */
public protocol MessageAttachment {
    /**
     - returns:
     The file info of the attachment.
     */
    func getFileInfo() -> FileInfo
    
    /**
     - returns:
     The files info of the attachment.
     */
    func getFilesInfo() -> [FileInfo]
    
    /**
     - returns:
     Attachment state.
     */
    func getState() -> AttachmentState
    
    /**
     - returns:
     Attachment upload progress as a percentage.
     */
    func getDownloadProgress() -> Int64?
    
    /**
     - returns:
     Type of error in case of problems during attachment upload.
     */
    func getErrorType() -> String?
    
    /**
     - returns:
     A message with the reason for the error during loading.
     */
    func getErrorMessage() -> String?
    
}

/**
 Shows the state of the attachment.
 - seealso:
 `MessageAttachment.getState()`
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 */
public enum AttachmentState {
    
    /**
     Some error occurred during loading.
     */
    case error
    
    /**
     File is available for download.
     */
    case ready
    
    /**
     The file is uploaded to the server.
     */
    case upload
    
    /**
     The file is checked by server.
     */
    case externalChecks
}

/**
Contains information about attachment properties.
- seealso:
`MessageAttachment.getFileInfo()`
*/
public protocol FileInfo {
    
    /**
     - returns:
     MIME-type of an attachment file.
     */
    func getContentType() -> String?
    
    /**
     - returns:
     Name of an attachment file.
     */
    func getFileName() -> String
    
    /**
     - seealso:
     `ImageInfo` protocol.
     - returns:
     If a file is an image, returns information about an image; in other cases returns nil.
     */
    func getImageInfo() -> ImageInfo?
    
    /**
     - returns:
     Attachment file size in bytes.
     */
    func getSize() -> Int64?
    
    /**
     - returns:
     Attachment file GUID.
     */
    func getGuid() -> String?
    
    /**
     - important:
     Notice that this URL is short-living and is tied to a session.
     - returns:
     URL of attached file.
     */
    func getURL() -> URL?
    
}

/**
 Provides information about an image.
 - seealso:
 `FileInfo.getImageInfo()`
 */
public protocol ImageInfo {
    
    /**
     Returns a URL String of an image thumbnail.
     The maximum width and height is usually 300 px but it can be adjusted at server settings.
     To get an actual preview size before file uploading is completed, use the following code:
     ````
        let THUMB_SIZE = 300
        var width = imageInfo.getWidth()
        var height = imageInfo.getHeight()
        if (height > width) {
            width = (THUMB_SIZE * width) / height
            height = THUMB_SIZE
        } else {
            height = (THUMB_SIZE * height) / width
            width = THUMB_SIZE
        }
        ````
     - important:
     Notice that this URL is short-living and is tied to a session.
     - returns:
     URL of reduced image.
     */
    func getThumbURL() -> URL
    
    /**
     - returns:
     Height of an image in pixels.
     */
    func getHeight() -> Int?
    
    /**
     - returns:
     Width of an image in pixels.
     */
    func getWidth() -> Int?
}

/**
 Provides information about a keyboard from script board.
 - seealso:
 `Message.getKeyboard()`
 */
public protocol Keyboard {
    
    /**
     - returns:
     Keyboard buttons.
     */
    func getButtons() -> [[KeyboardButton]]
    
    /**
     - returns:
     Kayboard state.
     */
    func getState() -> KeyboardState
    
    /**
     - returns:
     Keyboard response.
     */
    func getResponse() -> KeyboardResponse?
}

/**
 Supported keyboard States.
 - seealso:
 `Keyboard.getState()`
 */
public enum KeyboardState {
    
    /**
     A keyboard is waiting for answer.
     */
    case pending
    
    @available(*, unavailable, renamed: "pending")
    case PENDING
    
    /**
     A keyboard has response.
     */
    case completed
    
    @available(*, unavailable, renamed: "completed")
    case COMPLETED
    
    /**
     A keyboard cancelled without response.
     */
    case canceled
    
    @available(*, unavailable, renamed: "canceled")
    case CANCELLED
}

/**
 Provides information about a keyboard response to script board.
 - seealso:
 `Message.getKeyboard()`
 */
public protocol KeyboardResponse {
    
    /**
     - returns:
     ID of a button.
     */
    func getButtonID() -> String
    
    /**
     - returns:
     ID of a message.
     */
    func getMessageID() -> String
}

/**
 Keyboard button.
 - seealso:
 `Keyboard.getButtons()`
 */
public protocol KeyboardButton {
    
    /**
     - returns:
     ID of a button.
     */
    func getID() -> String
    
    /**
     - returns:
     Text of a button.
     */
    func getText() -> String
    
    /**
     - returns:
     Config of a button.
     */
    func getConfiguration() -> Configuration?
    
    /**
     - returns:
     Params of a button.
     */
    func getParams() -> Params?
}

/**
 Keyboard button config.
 */
public protocol Configuration {
    
    /**
     - returns:
     Is button active or not.
     */
    func isActive() -> Bool
    
    /**
     - returns:
     Button type.
     */
    func getButtonType() -> ButtonType
    
    /**
     - returns:
     Data a button.
     */
    func getData() -> String
    
    /**
     - returns:
     Button state.
     */
    func getState() -> ButtonState
}

/**
 Keyboard button params.
 */
public protocol Params {
    
    /**
     */
    func getAction() -> String?
    
    /**
     */
    func getType() -> ParamsButtonType?
    
    /**
     */
    func getColor() -> String?
}


/**
 Keyboard request.
 - seealso:
 `Message.getRequest()`
 */
public protocol KeyboardRequest {
    
    /**
     - returns:
     Request button.
     */
    func getButton() -> KeyboardButton
    
    /**
     - returns:
     Request message ID.
     */
    func getMessageID() -> String
}

/**
 Qoute.
 - seealso:
 `Message.getQuote()`
 */
public protocol Quote {
    /**
     - returns:
     Author ID.
     */
    func getAuthorID() -> String?
    
    /**
     - returns:
     Author ID.
     */
    func getMessageAttachment() -> FileInfo?
 
    /**
     - returns:
     Author ID.
     */
    func getMessageTimestamp() -> Date?
    
    /**
     - returns:
     Message ID.
     */
    func getMessageID() -> String?
    
    /**
     - returns:
     Message text.
     */
    func getMessageText() -> String?
    
    /**
     - returns:
     Message type.
     */
    func getMessageType() -> MessageType?
    
    /**
     - returns:
     Sender name.
     */
    func getSenderName() -> String?
    
    /**
     - returns:
     Quote type.
     */
    func getState() -> QuoteState
}

/**
 Contains information about sticker.
 - seealso:
 `Message.getSticker()`
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 */
public protocol Sticker {
    
    /**
     - returns:
     Sticker ID.
     */
    func getStickerId() -> Int
}

/**
 Supported quote states.
 - seealso:
 `Quote.getType()`
 */
public enum QuoteState {
    
    /**
     Quoute is loading.
     */
    case pending
    
    @available(*, unavailable, renamed: "pending")
    case PENDING
    
    /**
     Quoute loaded.
     */
    case filled
    
    @available(*, unavailable, renamed: "filled")
    case FILLED
    
    /**
     Quote message is not found on server.
     */
    case notFound
    
    @available(*, unavailable, renamed: "notFound")
    case NOT_FOUND
}

/**
 Supported file states.
 - seealso:
 `File`
 */
public enum FileState {
    
    /**
     File uploading error.
     */
    case error
    
    /**
     File uploaded.
     */
    case ready
    
    /**
     File is uploading
     */
    case upload
    
    /**
     The file is checked by server.
     */
    case externalChecks
}

/**
 Supported message types.
 - seealso:
 `Message.getType()`
 */
public enum MessageType {
    
    /**
     A message from operator which requests some actions from a visitor.
     E.g. choose an operator group by clicking on a button in this message.
     - seealso:
     `Message.getData()`
     */
    case actionRequest
    
    @available(*, unavailable, renamed: "actionRequest")
    case ACTION_REQUEST
    
    /**
     Message type that is received after operator clicked contacts request button.
     - important:
     There's no this functionality automatic support yet. All payload is transfered inside standard text field.
     - seealso:
     `Message.getText()`
     */
    case contactInformationRequest
    
    @available(*, unavailable, renamed: "contactInformationRequest")
    case CONTACTS_REQUEST
    
    /**
     A message sent by an operator which contains an attachment.
     - important:
     Notice that the method `MessageData.getAttachment()` may return nil even for messages of this type. E.g. if a file is being sent.
     - seealso:
     `MessageData.getAttachment()`
     */
    case fileFromOperator
    
    @available(*, unavailable, renamed: "fileFromOperator")
    case FILE_FROM_OPERATOR
    
    /**
     A message sent by a visitor which contains an attachment.
     - important:
     Notice that the method `MessageData.getAttachment()` may return nil even for messages of this type. E.g. if a file is being sent.
     - seealso:
     `MessageData.getAttachment()`
     */
    case fileFromVisitor
    
    @available(*, unavailable, renamed: "fileFromVisitor")
    case FILE_FROM_VISITOR
    
    /**
     A system information message.
     Messages of this type are automatically sent at specific events. E.g. when starting a chat, closing a chat or when an operator joins a chat.
     */
    case info
    
    @available(*, unavailable, renamed: "info")
    case INFO
    
    /**
     Message with buttons for visitor choise.
     Messages of this type are sent by script robot.
     */
    case keyboard
    
    @available(*, unavailable, renamed: "keyboard")
    case KEYBOARD
    
    /**
     Response to messages of `keyboard` type.
     */
    case keyboardResponse
    
    @available(*, unavailable, renamed: "keyboardResponse")
    case KEYBOARD_RESPONSE
    
    /**
     A text message sent by an operator.
     - seealso:
     `Message.getText()`
     */
    case operatorMessage
    
    @available(*, unavailable, renamed: "operatorMessage")
    case OPERATOR
    
    /**
     A system information message which indicates that an operator is busy and can't reply to a visitor at the moment.
     */
    case operatorBusy
    
    @available(*, unavailable, renamed: "operatorBusy")
    case OPERATOR_BUSY
    
    /**
     A text message sent by a visitor.
     - seealso:
     `Message.getText()`
     */
    case visitorMessage
    
    @available(*, unavailable, renamed: "visitorMessage")
    case VISITOR
    
    /**
     A sticker message sent by a visitor.
     - seealso:
     `Message.getText()`
     */
    case stickerVisitor
}

/**
 Until a message is sent to the server, is received by the server and is spreaded among clients, message can be seen as "being send"; at the same time `Message.getSendStatus()` will return `sending`. In other cases - `sent`.
 */
public enum MessageSendStatus {
    
    /**
     A message is being sent.
     */
    case sending
    
    @available(*, unavailable, renamed: "sending")
    case SENDING
    
    /**
     A message had been sent to the server, received by the server and was spreaded among clients.
     */
    case sent
    
    @available(*, unavailable, renamed: "sent")
    case SENT
    
}

public enum ButtonType {
    
    case url
    
    case insert
    
}

public enum ButtonState {
    
    case showing
    
    case showingSelected
    
    case hidden
    
}

public enum ParamsButtonType {
    
    case url
    
    case action
    
}
