
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
    
    func showDepartmentListDialog(
        withDepartmentList departmentList: [Department],
        action: @escaping (String) -> Void,
        senderButton: UIView?,
        cancelAction: (() -> Void)?
    ) {
        alertController = UIAlertController(
            title: "Contact topic".localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        for department in departmentList {
            let departmentAction = UIAlertAction(
                title: department.getName(),
                style: .default,
                handler: { _ in
                    action(department.getKey())
                }
            )
            
            alertController.addAction(departmentAction)
        }
        
        let alertAction = UIAlertAction(
            title: "Cancel".localized,
            style: .cancel,
            handler: { _ in cancelAction?() })
        
        alertController.addAction(alertAction)
        
        if let popoverController = alertController.popoverPresentationController {
            
            if senderButton == nil {
                fatalError("No source view for presenting alert popover")
            }
            popoverController.permittedArrowDirections = .down
            popoverController.sourceView = senderButton
            popoverController.sourceRect = CGRect(x: -10, y: -10,
                                                  width: senderButton?.bounds.width ?? 0,
                                                  height: senderButton?.bounds.height ?? 0)
        }
        
        delegate?.present(alertController, animated: true)
    }
    
    func showSendFailureDialog(
        withMessage message: String,
        title: String,
        action: (() -> Void)? = nil
    ) {
        showDialog(
            withMessage: message,
            title: title,
            buttonTitle: "OK".localized,
            action: action
        )
    }
    
    func showChatClosedDialog() {
        showDialog(
            withMessage: "Chat finished.".localized,
            title: nil,
            buttonTitle: "OK".localized
        )
    }
    
    func showCreatingSessionFailureDialog(withMessage message: String) {
        showDialog(
            withMessage: message,
            title: "Session creation failed".localized,
            buttonTitle: "OK".localized
        )
    }
    
    func showFileLoadingFailureDialog(withError error: Error) {
        showDialog(
            withMessage: error.localizedDescription,
            title: "LoadError".localized,
            buttonTitle: "OK".localized
        )
    }
    
    func showFileSavingFailureDialog(withError error: Error) {
        let action = getGoToSettingsAction()
        showDialog(
            withMessage: "SaveFileErrorMessage".localized,
            title: "Save error".localized,
            buttonTitle: "Go to Settings".localized,
            buttonStyle: .default,
            action: action
        )
    }
    
    func showImageSavingFailureDialog(withError error: NSError) {
        let action = getGoToSettingsAction()

        showDialog(
            withMessage: "SaveErrorMessage".localized,
            title: "SaveError".localized,
            buttonTitle: "Go to Settings".localized,
            buttonStyle: .default,
            action: action
        )
    }
    
    func showImageSavingSuccessDialog() {
        showDialog(
            withMessage: "The image has been saved to your photos".localized,
            title: "Saved!".localized,
            buttonTitle: "OK".localized
        )
    }
    
    func showNoCurrentOperatorDialog() {
        showDialog(
            withMessage: "There is no current agent to rate".localized,
            title: "No agents available".localized,
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
    
    func showOperatorInfo(withMessage message: String) {
        showDialog(
            withMessage: message,
            title: "Operator Info".localized,
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
