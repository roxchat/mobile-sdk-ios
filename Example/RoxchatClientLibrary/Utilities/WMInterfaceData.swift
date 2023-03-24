
import UIKit

class WMInterfaceData {
    static var shared = WMInterfaceData()
    private var _keyboardHeight: CGFloat = 346
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Methods
    func screenWidth() -> CGFloat {
        return AppDelegate.shared.window?.frame.width ?? 0
    }
    func screenHeight() -> CGFloat {
        return AppDelegate.shared.window?.frame.height ?? 0
    }
    
    func keyboardHeight() -> CGFloat {
        return _keyboardHeight
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            _keyboardHeight = keyboardFrame.cgRectValue.height
        }
    }
}
