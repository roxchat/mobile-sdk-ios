
import UIKit

protocol WMFixedWidthViewDelegate: AnyObject {
    func viewWillResize(_ view: UIView)
}

class WMFixedWidthView: UIView {
    weak var delegate: WMFixedWidthViewDelegate?
    var widthConstraint: NSLayoutConstraint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fixViewSize()
    }
    
    func fixViewSize() {
        if let superview = self.superview {
            
            if self.frame.width != superview.frame.width {
                self.widthConstraint?.constant = superview.frame.width
                self.delegate?.viewWillResize(self)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        
        self.widthConstraint = widthConstraint
        NSLayoutConstraint.activate([widthConstraint])
        fixViewSize()
    }
}

class WMFixedContentSizeView: UIView {

    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fixViewSize()
    }
    
    func fixViewSize() {
        if let subview = self.subviews.first {
            
            if self.frame.height != subview.frame.height {
                self.heightConstraint?.constant = subview.frame.height
            }
                
            if self.frame.width != subview.frame.width {
                self.widthConstraint?.constant = subview.frame.width
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        
        self.widthConstraint = widthConstraint
        self.heightConstraint = heightConstraint
        NSLayoutConstraint.activate([widthConstraint, heightConstraint])
        fixViewSize()
    }
}
