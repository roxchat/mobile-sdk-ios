
import Foundation
import RoxchatClientLibrary

protocol MessageCounterDelegate: AnyObject {
    func changed(newMessageCount: Int)
    func updateLastMessageIndex(completionHandler: ((Int) -> ())?)
    func updateLastReadMessageIndex(completionHandler: ((Int) -> ())?)
}

class MessageCounter {

    var lastReadMessageIndex: Int = 0
    private var lastMessageIndex: Int = 0
    private var actualNewMessageCount: Int = 0

    private weak var delegate: MessageCounterDelegate?

    init(delegate: MessageCounterDelegate? = nil) {
        self.delegate = delegate
    }

    func set(lastReadMessageIndex: Int) {
        if lastReadMessageIndex > self.lastReadMessageIndex {
            self.lastReadMessageIndex = lastReadMessageIndex
            updateActualNewMessageCount()
        }
    }

    func set(lastMessageIndex: Int) {
        self.lastMessageIndex = lastMessageIndex
        updateActualNewMessageCount()
    }

    func getActualNewMessageCount() -> Int {
        return actualNewMessageCount
    }

    func hasNewMessages() -> Bool {
        return actualNewMessageCount > 0
    }

    private func updateActualNewMessageCount() {
        if actualNewMessageCount != lastMessageIndex - lastReadMessageIndex {
            actualNewMessageCount = lastMessageIndex - lastReadMessageIndex
            delegate?.changed(newMessageCount: actualNewMessageCount)
        }
    }
}

extension MessageCounter: UnreadByVisitorMessageCountChangeListener {
    func changedUnreadByVisitorMessageCountTo(newValue: Int) {
        delegate?.updateLastMessageIndex() { [weak self] index in
            self?.set(lastMessageIndex: index)
        }
        delegate?.updateLastReadMessageIndex() { [weak self] index in
            self?.set(lastReadMessageIndex: index)
        }
    }
}
