
import UIKit

extension WMSettingsViewController {
    // MARK: - Methods
    func setupColorScheme() {
        view.backgroundColor = backgroundViewColour
        
        saveButton.backgroundColor = saveButtonBackgroundColour
        saveButton.setTitleColor(saveButtonTitleColour, for: .normal)
    }
    
    // MARK: - Private methods
    func setupNavigationItem() {
        let titleView = getTitleView()
        self.navigationItem.titleView = titleView
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
        pageTitleTextField.delegate = self
        accountNameTextField.delegate = self
        locationTextField.delegate = self
        pageTitleTextField.delegate = self
    }
    
    private func getTitleView() -> UIView {

        let label = UILabel()
        let imageView = UIImageView()
        let titleView = UIView()

        titleView.addSubview(imageView)
        titleView.addSubview(label)

        setupTitleImageView(imageView)
        setupTitleLabelView(label: label)

        setupTitleViewConstraints(titleView: titleView,
                                  imageView: imageView,
                                  label: label)

        return titleView
    }


    private func setupTitleImageView(_ imageView: UIImageView) {
        let toogleTestModeGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(toogleTestMode)
        )
        imageView.image = navigationBarTitleImageViewImage
        imageView.contentMode = .scaleAspectFill
        toogleTestModeGestureRecognizer.numberOfTapsRequired = 5
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(toogleTestModeGestureRecognizer)
    }

    private func setupTitleLabelView(label: UILabel) {
        label.textColor = versionLabelFontColor
        label.font = UIFont.systemFont(ofSize: 12.69, weight: .regular)
        label.textAlignment = .center
        if let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
           let releaseVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
            label.text = "v. \(releaseVersion) (\(buildVersion))"
        }
    }


    private func setupTitleViewConstraints(
        titleView: UIView,
        imageView: UIView,
        label: UIView
    ) {
        let navigationBarHeight = navigationController?.navigationBar.frame.height
        titleView.snp.makeConstraints { make in
            make.width.equalTo(titleView.snp.height).multipliedBy(2)
            make.height.equalTo(navigationBarHeight ?? 44)
        }

        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2.2)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(6)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
