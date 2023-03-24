
import Foundation
import RoxchatClientLibrary

extension ChatViewController: WMDialogPopoverDelegate {
    func addQuoteReplyBar() {
        self.toolbarView.addQuoteBarForMessage(self.selectedMessage, delegate: self)
        if self.selectedMessage?.isFile() ?? false && self.selectedMessage?.getData()?.getAttachment()?.getFileInfo().getImageInfo() != nil {
            self.toolbarView.quoteView.quoteImageView.isUserInteractionEnabled = true
            self.toolbarView.quoteView.quoteImageView.gestureRecognizers = nil
        }
        
        self.toolbarView.addQuoteBarForMessage(self.selectedMessage, delegate: self)
    }
    
    func hideQuoteView() {
        self.toolbarView.removeQuoteEditBar()
    }
    
    func addQuoteEditBar() {
        self.toolbarView.addQuoteEditBarForMessage(self.selectedMessage, delegate: self)
    }
    
    func likeMessage() {
        self.reactMessage(reaction: ReactionString.like)
    }
    
    func dislikeMessage() {
        self.reactMessage(reaction: ReactionString.dislike)
    }
    
    @objc
    func hideOverlayWindow() {
        AppDelegate.keyboardHidden(false)
    }
    
    func removeQuoteEditBar() {
        self.toolbarView.removeQuoteEditBar()
    }
}
