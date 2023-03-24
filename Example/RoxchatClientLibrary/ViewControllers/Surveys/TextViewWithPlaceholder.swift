
import UIKit

class TextViewWithPlaceholder: UITextView {
    var placeholderLabel: UILabel = UILabel.createUILabel(systemFontSize: 16, numberOfLines: 0)
    func setPlaceholder(_ placeholder: String, placeholderColor: UIColor) {
        self.addSubview(placeholderLabel)
        self.placeholderLabel.font = self.font
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = placeholderColor
        self.placeholderLabel.snp.remakeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview().offset(6)
            make.width.equalToSuperview()
        }
        self.textViewDidChange()
    }
    
    func textViewDidChange() {
        if self.text.isEmpty {
            UIView.animate(withDuration: 0.1) {
                self.placeholderLabel.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.placeholderLabel.alpha = 0.0
            }
        }
    }
}
