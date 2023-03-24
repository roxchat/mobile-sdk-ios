
import UIKit

extension UITextField {
    func setTextFixed(_ text: String) {
        self.text = text
        // Workaround to trigger textViewDidChange
        self.replace(
            self.textRange(
                from: self.beginningOfDocument,
                to: self.endOfDocument) ?? UITextRange(),
            withText: text
        )
    }
}
