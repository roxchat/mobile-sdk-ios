
import UIKit
import RoxchatClientLibrary

class WMVisitorQuoteMessageCell: WMQuoteMessageCell {
     
    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            self.sharpCorner(view: messageView, visitor: true)
        }
        return setup
    }
}
