
import UIKit

extension UIViewController {
    
    // MARK: - Methods
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Private methods
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    public func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    static func loadViewControllerFromXib() -> Self {
        let identifier = "\(Self.self)"
        return Self(nibName: identifier, bundle: nil)
    }
}
