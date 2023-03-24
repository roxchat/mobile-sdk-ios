
import UIKit
import RoxchatClientLibrary

class WMVisitorFileCell: FileMessage {
    
    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            self.sharpCorner(view: messageView, visitor: true)
        }
        return setup
    }
}
