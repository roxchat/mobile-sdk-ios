import UIKit
import RoxchatClientLibrary

extension WMSettingsViewController {
    
    // MARK: - Methods
    
    func setupColorScheme() {
        view.backgroundColor = backgroundViewColour
        
        saveButton.backgroundColor = saveButtonBackgroundColour
        saveButton.setTitleColor(saveButtonTitleColour, for: .normal)
    }
    
    // MARK: - Private methods
    
    func setupNavigationItem() {
        let titleLabel = UILabel()
        let toogleTestModeGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(toogleTestMode)
        )
        toogleTestModeGestureRecognizer.numberOfTapsRequired = 5
        titleLabel.text = "Settings".localized
        titleLabel.textColor = .white
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(toogleTestModeGestureRecognizer)
        self.navigationItem.titleView = titleLabel
    }
    
    func setupLabels() {
        for hintLabel in [
            accountNameHintLabel,
            locationHintLabel
        ] {
            guard let hintLabel = hintLabel else { continue }
            hintLabel.alpha = 0.0
        }
    }

    func setupTextFieldsDelegate() {
        accountNameTextField.delegate = self
        locationTextField.delegate = self
    }
    
    func setupSelectVisitorCell() {
        let visitorRow: SelectVisitorViewController.VisitorRows
        switch DemoVisitor.currentVisitor {
        case .fedor:
            visitorRow = .fedor
        case .semion:
            visitorRow = .semion
        default:
            visitorRow = .unauthorized
        }
        selectVisitorCell.usernameLabel.text = visitorRow.rawValue.localized
    }

}
