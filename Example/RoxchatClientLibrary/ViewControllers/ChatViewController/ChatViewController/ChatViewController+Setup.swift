
import UIKit
import RoxchatClientLibrary

extension UILabel {
    static func createUILabel(
        textAlignment: NSTextAlignment = .left,
        systemFontSize: CGFloat,
        systemFontWeight: UIFont.Weight = .regular,
        numberOfLines: Int = 1
    ) -> UILabel {
        let label = UILabel()
        label.textAlignment = textAlignment
        label.font = .systemFont(ofSize: systemFontSize, weight: .regular )
        label.numberOfLines = numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

extension ChatViewController {
    
    func createTypingIndicator() -> TypingIndicator {
        let view = TypingIndicator()
        view.circleDiameter = 5.0
        view.circleColour = UIColor.white
        view.animationDuration = 0.5
        return view
    }
    
    func createTextInputTextView() -> UITextView {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
    
    func createUIView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func createUIImageView(
        contentMode: UIView.ContentMode = .scaleAspectFit
    ) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = contentMode
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    func createUIButton(type: UIButton.ButtonType) -> UIButton {
        let button = UIButton(type: type)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func createCustomUIButton(type: UIButton.ButtonType) -> UIButton {
        let button = CustomUIButton(type: type)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func setupNavigationBar() {
        setupTitleView()
        setupRightBarButtonItem()
    }
    
    func addDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissViewKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    func addClearTextViewSelectionGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clearTextViewSelection))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func setupTestView() {
        if WMTestManager.testModeEnabled() {
            chatTestView.setupView(delegate: self)
            self.view.addSubview(chatTestView)
            chatTestView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            chatTestView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            chatTestView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.view.bringSubviewToFront(chatTestView)
        }
    }
    
    func setupTitleView() {
        // TitleView
        titleViewOperatorNameLabel.text = "Roxchat demo-chat".localized
        titleViewOperatorNameLabel.textColor = .white
        titleViewOperatorNameLabel.highlightedTextColor = .lightGray
        titleViewOperatorStatusLabel.text = "No agent".localized
        titleViewOperatorStatusLabel.textColor = .white
        titleViewOperatorStatusLabel.highlightedTextColor = .lightGray
        
        let customViewForOperatorNameAndStatus = CustomUIView()
        customViewForOperatorNameAndStatus.isUserInteractionEnabled = true
        customViewForOperatorNameAndStatus.translatesAutoresizingMaskIntoConstraints = false
        customViewForOperatorNameAndStatus.addSubview(titleViewOperatorNameLabel)
        titleViewOperatorNameLabel.snp.remakeConstraints { (make) -> Void in
            make.leading.top.trailing.equalToSuperview()
        }
        
        customViewForOperatorNameAndStatus.addSubview(titleViewOperatorStatusLabel)
        titleViewOperatorStatusLabel.snp.remakeConstraints { (make) -> Void in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(titleViewOperatorNameLabel.snp.bottom)
                .offset(2)
        }
        
        customViewForOperatorNameAndStatus.addSubview(titleViewTypingIndicator)
        titleViewTypingIndicator.snp.remakeConstraints { (make) -> Void in
            make.width.equalTo(30.0)
            make.height.equalTo(titleViewTypingIndicator.snp.width).multipliedBy(0.5)
            make.centerY.equalTo(titleViewOperatorStatusLabel.snp.centerY)
            make.trailing.equalTo(titleViewOperatorStatusLabel.snp.leading)
                .inset(2)
        }
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(titleViewTapAction)
        )
        customViewForOperatorNameAndStatus.addGestureRecognizer(gestureRecognizer)
        navigationItem.titleView = customViewForOperatorNameAndStatus
    }
    
    private func setupRightBarButtonItem() {
        // RightBarButtonItem
        titleViewOperatorAvatarImageView.image = UIImage()
        
        let customViewForOperatorAvatar = createUIView()
        customViewForOperatorAvatar.addSubview(titleViewOperatorAvatarImageView)
        
        titleViewOperatorAvatarImageView.snp.remakeConstraints { (make) -> Void in
            make.trailing.equalToSuperview()
                .inset(-14)
            make.width.equalTo(titleViewOperatorAvatarImageView.snp.height)
            make.top.bottom.equalToSuperview()
                .inset(2)
        }
        
        let customRightBarButtonItem = UIBarButtonItem(
            customView: customViewForOperatorAvatar
        )
        
        navigationItem.rightBarButtonItem = customRightBarButtonItem
        navigationItem.rightBarButtonItem?.action = #selector(titleViewTapAction)
    }
    
    func configureNetworkErrorView() {
        
        self.connectionErrorView = ConnectionErrorView.loadXibView()
        self.connectionErrorView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 25)
        self.connectionErrorView.alpha = 0
        self.view.addSubviewWithSameWidth(connectionErrorView)
    }
    
    func configureThanksView() {
        
        self.thanksView = WMThanksAlertView.loadXibView()
        self.view.addSubviewWithSameWidth(thanksView)
        self.thanksView.hideWithoutAnimation()
    }
    
    func setupScrollButton() {
        view.addSubview(scrollButtonView)
        scrollButtonView.initialSetup()
        scrollButtonView.setScrollButtonBackgroundImage(scrollButtonImage, state: .normal)
        scrollButtonView.addTarget(
            self,
            action: #selector(scrollTableView(_:)),
            for: .touchUpInside)
        scrollButtonView.setScrollButtonViewState(.hidden)
        setupScrollButtonViewConstraints()
    }

    private func setupScrollButtonViewConstraints() {
        scrollButtonView.snp.makeConstraints { make in
            let scrollButtonPadding: CGFloat = 22
            if #available(iOS 11.0, *) {
                make.trailing.equalTo(view.safeAreaLayoutGuide).inset(scrollButtonPadding)
            } else {
                make.trailing.equalToSuperview().inset(scrollButtonPadding)
            }
            make.bottom.equalToSuperview().inset(toolbarView.frame.height + scrollButtonPadding)
            make.height.equalTo(scrollButtonView.snp.width)
            make.width.equalTo(34)
        }
    }
    
    func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            chatTableView?.refreshControl = newRefreshControl
        } else {
            chatTableView?.addSubview(newRefreshControl)
        }
        newRefreshControl.layer.zPosition -= 1
        newRefreshControl.addTarget(
            self,
            action: #selector(requestMessages),
            for: .valueChanged
        )
        newRefreshControl.tintColor = refreshControlTintColour
        let attributes = [NSAttributedString.Key.foregroundColor: refreshControlTextColour]
        newRefreshControl.attributedTitle = NSAttributedString(
            string: "Fetching more messages...".localized,
            attributes: attributes
        )
    }
    
    func configureNotifications() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    func setupServerSideSettingsManager() {
        roxchatServerSideSettingsManager.getServerSideSettings()
    }

    func setupAlreadyRatedOperators() {
        guard let alreadyRatedOperatorsDictionary = WMKeychainWrapper.standard.dictionary(
            forKey: keychainKeyRatedOperators) as? [String: Bool] else {
            return
        }
        alreadyRatedOperators = alreadyRatedOperatorsDictionary
    }
}
