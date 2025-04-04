
import UIKit
import RoxchatClientLibrary


final class UIAlertHandler {
    
    // MARK: - Properties
    
    private weak var delegate: UIViewController?
    private var alertController: UIAlertController!
    
    // MARK: - Initializer
    
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    func showDialog(
        withMessage message: String,
        title: String?,
        buttonTitle: String = "OK".localized,
        buttonStyle: UIAlertAction.Style = .cancel,
        action: (() -> Void)? = nil
    ) {
        alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(
            title: buttonTitle,
            style: buttonStyle,
            handler: { _ in
                action?()
            })
        
        alertController.addAction(alertAction)
        
        if buttonStyle != .cancel {
            let alertActionOther = UIAlertAction(
                title: "Cancel".localized,
                style: .cancel)
            alertController.addAction(alertActionOther)
        }
        
        delegate?.present(alertController, animated: true)
    }
    
    func showCreatingSessionFailureDialog(withMessage message: String) {
        showDialog(
            withMessage: message,
            title: "Session creation failed".localized,
            buttonTitle: "OK".localized
        )
    }
    
    func showSettingsAlertDialog(withMessage message: String) {
        showDialog(
            withMessage: message,
            title: "InvalidSettings".localized,
            buttonTitle: "OK".localized
        )
    }

    func showAlertForAccountName() {
        showDialog(
            withMessage: "Alert account name".localized,
            title: "Account".localized,
            buttonTitle: "OK".localized
        )
    }
    
    func showAlertForInvalidAccountName() {
        showDialog(
            withMessage: "Invalid account name".localized,
            title: "Account".localized,
            buttonTitle: "OK".localized
        )
    }
    
    // MARK: - Private methods
    
    private func getGoToSettingsAction() -> (() -> Void) {
        return {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (_) in
                })
            }
        }
    }
    
    private func dismiss() {
        let time = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.alertController.dismiss(animated: true, completion: nil)
        }
    }
}
