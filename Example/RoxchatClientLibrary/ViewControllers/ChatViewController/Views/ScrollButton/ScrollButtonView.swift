
import UIKit

class ScrollButtonView: UIView {

    @IBOutlet private var scrollButton: UIButton!
    @IBOutlet private var unreadMessageCounterLabel: UILabel!

    func initialSetup() {
        unreadMessageCounterLabel.layer.cornerRadius = unreadMessageCounterLabel.bounds.width / 2
        unreadMessageCounterLabel.layer.borderWidth = 1
        unreadMessageCounterLabel.layer.borderColor = unreadMessagesBorderColour.cgColor
    }

    func setScrollButtonBackgroundImage(_ image: UIImage?, state: UIControl.State) {
        scrollButton.setBackgroundImage(image, for: state)
    }

    func addTarget(_ target: Any, action: Selector, for event: UIControl.Event) {
        scrollButton.addTarget(target, action: action, for: event)
    }

    func setScrollButtonViewState(_ state: ScrollButtonViewState) {
        switch state {
        case .hidden:
            isHidden = true
            scrollButton.isHidden = true
            unreadMessageCounterLabel.isHidden = true
        case .visible:
            isHidden = false
            scrollButton.isHidden = false
            unreadMessageCounterLabel.isHidden = true
        case .newMessage:
            isHidden = false
            scrollButton.isHidden = false
            unreadMessageCounterLabel.isHidden = false
        }
    }

    func setNewMessageCount(_ count: Int) {
        unreadMessageCounterLabel.text = "\(count)"
    }

    func unreadMessagesCount() -> Int {
        return Int(unreadMessageCounterLabel.text ?? "") ?? 0
    }
}


enum ScrollButtonViewState {
    case hidden
    case visible
    case newMessage
}
