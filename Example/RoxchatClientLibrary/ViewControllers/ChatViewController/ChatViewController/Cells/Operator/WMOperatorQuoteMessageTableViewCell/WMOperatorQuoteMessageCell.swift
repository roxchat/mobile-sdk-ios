
import UIKit
import RoxchatClientLibrary

class WMOperatorQuoteMessageCell: WMQuoteMessageCell {
    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            self.sharpCorner(view: messageView, visitor: false)
        }
        return setup
    }
}
