
import UIKit
import RoxchatClientLibrary

class WMToolbarView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    var templatesTooltipView = WMTemplatesTooltipView.loadXibView()
    var quoteView = WMQuoteView.loadXibView()
    var messageView = WMNewMessageView.loadXibView()
    
    var heightConstraint: NSLayoutConstraint?
    var quoteViewTopConstraint: NSLayoutConstraint?

    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        messageView.frame.size.width = self.frame.size.width
        self.addSubview(messageView)
        
        self.bindWidthToSuperview()
        self.bindHeightToSuperview()
        
        messageView.bindWidthToSuperview()

        let messageViewBottomConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: messageView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        self.addConstraint(messageViewBottomConstraint)

        self.heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: messageView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
        self.addConstraint(heightConstraint!)
    }
    
    func showHideTooltipsView() -> Bool {
        return  UIDevice.current.orientation.isLandscape &&
                UIDevice.current.userInterfaceIdiom == .phone &&
                self.quoteView.superview != nil
    }
    
    override func layoutSubviews() {
        var additionalHeight: CGFloat = 0.0
        let quoteViewPosition: CGFloat = 0.0
        
        if self.quoteView.superview != nil {
            additionalHeight += self.quoteView.frame.height
        }
        
        if let quoteViewTopConstraint = self.quoteViewTopConstraint {
            if quoteViewTopConstraint.constant != quoteViewPosition {
                quoteViewTopConstraint.constant = quoteViewPosition
            }
        }
        
        if self.heightConstraint?.constant != additionalHeight {
            self.heightConstraint?.constant = additionalHeight
        }
        super.layoutSubviews()
        
    }
    
    func addQuoteEditBarForMessage(_ message: Message?, delegate: WMDialogCellDelegate) {
        if let message = message {
            self.quoteView.addQuoteEditBarForMessage(message, delegate: delegate)
            self.addSubview(quoteView)
            
            self.messageView.setMessageText(message.getText())

            quoteView.bindWidthToSuperview()
            
            self.quoteViewTopConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: quoteView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            self.addConstraint(self.quoteViewTopConstraint!)
            self.setNeedsLayout()
        } else {
            self.quoteView.removeFromSuperview()
        }
    }
    
    func addQuoteBarForMessage(_ message: Message?, delegate: WMDialogCellDelegate) {
        if let message = message {
            self.quoteView.addQuoteBarForMessage(message, delegate: delegate)
            self.addSubview(quoteView)

            quoteView.bindWidthToSuperview()
            
            self.quoteViewTopConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: quoteView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            self.addConstraint(self.quoteViewTopConstraint!)
            self.setNeedsLayout()
        } else {
            self.quoteView.removeFromSuperview()
        }
    }
    
    func removeQuoteEditBar() {
        self.quoteView.removeFromSuperview()
    }
    
    func quoteBarIsVisible() -> Bool {
        return quoteView.superview != nil
    }
}
