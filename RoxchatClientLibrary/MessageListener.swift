
import Foundation

/**
 Delegate protocol that provide methods to handle changes in message stream.
 - seealso:
 `MessageStream.newMessageTracker(messageListener:)`
 */
public protocol MessageListener: class {
    
    /**
     Called when added a new message.
     If `previousMessage == nil` then it should be added to the end of message history (the lowest message is added), in other cases the message should be inserted before the message (i.e. above in history) which was given as a parameter `previousMessage`.
     - important:
     Notice that this is a logical insertion of a message. I.e. calling this method does not necessarily mean receiving a new (unread) message. Moreover, at the first call `MessageTracker.getNextMessages(byLimit:completion:)` most often the last messages of a local history (i.e. which is stored on a user's device) are returned, and this method will be called for each message received from a server after a successful connection.
     - seealso:
     `Message` protocol.
     - parameter newMessage:
     Added message.
     - parameter previousMessage:
     A message after which it is needed to make a message insert. If `nil` then an insert is performed at the end of the list.
     */
    func added(message newMessage: Message,
               after previousMessage: Message?)
    
    /**
     Called when removing a message.
     - seealso:
     `Message` protocol.
     - parameter message:
     A message to be removed.
     */
    func removed(message: Message)
    
    /**
     Called when removed all the messages.
     */
    func removedAllMessages()
    
    /**
     Called when changing a message.
     `Message` is an immutable type and field values can not be changed. That is why message changing occurs as replacing one object with another. Thereby you can find out, for example, which certain message fields have changed by comparing an old and a new object values.
     - seealso:
     `Message` protocol.
     - parameter oldVersion:
     Message changed from.
     - parameter newVersion:
     Message changed to.
     */
    func changed(message oldVersion: Message,
                 to newVersion: Message)
    
}
