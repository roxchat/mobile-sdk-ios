
import Foundation

/**
 Message subtype which is used when message is sending by visitor at the moment.
 */
final class MessageToSend: MessageImpl {
    
    // MARK: - Initialization
    init(serverURLString: String,
         clientSideID: String,
         senderName: String,
         type: MessageType,
         text: String,
         timeInMicrosecond: Int64,
         data: MessageData? = nil,
         quote: Quote? = nil,
         sticker: Sticker? = nil) {
        super.init(serverURLString: serverURLString,
                   clientSideID: clientSideID,
                   serverSideID: nil,
                   keyboard: nil,
                   keyboardRequest: nil,
                   operatorID: nil,
                   quote: quote,
                   senderAvatarURLString: nil,
                   senderName: senderName,
                   sendStatus: .sending,
                   sticker: sticker,
                   type: type,
                   rawData: nil,
                   data: data,
                   text: text,
                   timeInMicrosecond: timeInMicrosecond,
                   historyMessage: false,
                   internalID: nil,
                   rawText: nil,
                   read: false,
                   messageCanBeEdited: false,
                   messageCanBeReplied: false,
                   messageIsEdited: false,
                   visitorReactionInfo: nil,
                   visitorCanReact: false,
                   visitorChangeReaction: false)
    }
    
}
