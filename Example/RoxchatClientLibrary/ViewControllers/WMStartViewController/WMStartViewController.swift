
import UIKit
import RoxchatClientLibrary
import RoxChatMobileWidget

final class WMStartViewController: UIViewController {

    // MARK: - Private Properties
    
    private var unreadMessageCounter: Int = 0

    private lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    private lazy var visitorFieldsManager = WMVisitorFieldsManager()

    // MARK: - Outlets
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var welcomeTextView: UITextView!
    @IBOutlet var startChatButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var unreadMessageCounterLabel: UILabel!

    @IBOutlet var logoConstraint: NSLayoutConstraint!
    @IBOutlet var welcomeConstraint: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkOrientation()
        setupStartChatButton()
        setupSettingsButton()
        setupLogoTapGestureRecognizer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Workaround for displaying correctly the position of the text inside weclomeTextView
        welcomeTextView.text = NSLocalizedString("xS6-J8-Sm9.text", tableName: "WMStartViewController", comment: "")
        welcomeTextView.sizeToFit()
        setupColorScheme()
        welcomeTextView.textContainer.lineFragmentPadding = 5
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.17
        let stringAttributes = [NSAttributedString.Key.paragraphStyle: style]
        welcomeLabel.attributedText = NSAttributedString(string: "Welcome to the RoxchatClientLibrary app!".localized, attributes: stringAttributes)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRoxchatSession()
        updateMessageCounter()
    }

    @IBAction func startChat(_ sender: Any? = nil) {
        presentChatViewController(
            openFromNotification: sender == nil,
            visitorData: visitorFieldsManager.getVisitorData(for: .currentVisitor)
        )
    }

    @IBAction func openSettings() {
        let settingsVc = WMSettingsViewController.loadViewControllerFromXib()
        navigationController?.pushViewController(settingsVc, animated: true)
    }

    // MARK: - Private methods
    @objc private func presentWMLogsViewController(_ gesture: UIGestureRecognizer) {
        if WMTestManager.testModeEnabled() {
            let logsViewController = WMLogsViewController.loadViewControllerFromXib()
            navigationController?.pushViewController(logsViewController, animated: true)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.checkOrientation()
    }

    private func checkOrientation() {
        DispatchQueue.main.async {
            let orientation = UIWindow.isLandscape
            self.logoConstraint.constant = orientation ? 0 : 108
            self.welcomeConstraint.constant = orientation ? 10 : 48
        }
    }

    private func setupStartChatButton() {
        startChatButton.layer.cornerRadius = 8.0
        startChatButton.layer.borderWidth = 1.0
        startChatButton.layer.borderColor = startChatButtonBorderColour
    }

    private func setupSettingsButton() {
        settingsButton.layer.cornerRadius = 8.0
        settingsButton.layer.borderWidth = 1.0
    }

    private func setupLogoTapGestureRecognizer() {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(presentWMLogsViewController(_:)))
        logoImageView.addGestureRecognizer(gesture)
        logoImageView.isUserInteractionEnabled = true
    }

    private func setupColorScheme() {
        view.backgroundColor = startViewBackgroundColour

        welcomeLabel.textColor = welcomeLabelTextColour

        welcomeTextView.textColor = welcomeTextViewTextColour
        welcomeTextView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: welcomeTextViewForegroundColour
        ]

        startChatButton.backgroundColor = startChatButtonBackgroundColour
        startChatButton.setTitleColor(startChatTitleColour, for: .normal)

        settingsButton.setTitleColor(settingsButtonTitleColour, for: .normal)

        settingsButton.layer.borderColor = settingButtonBorderColour.cgColor
    }

    private func updateMessageCounter() {
        DispatchQueue.main.async {
            self.unreadMessageCounterLabel.text = "New messages".localized + ": \(self.unreadMessageCounter)"
        }
    }

    private func presentChatViewController(openFromNotification: Bool, visitorData: Data? = nil) {
        RoxchatServiceController.currentSession.stopSession()
        
        let widget = ExternalWidgetBuilder().buildDefaultWidget(remoteNotificationSystem: .apns,
                                                                visitorFieldsData: visitorData,
                                                                roxchatLogger: WidgetLogManager.shared,
                                                                roxchatLoggerVerbosityLevel: .debug,
                                                                availableLogTypes: [.manualCall,
                                                                                    .messageHistory,
                                                                                    .networkRequest,
                                                                                    .undefined],
                                                                openFromNotification: openFromNotification
        )
        
        self.navigationController?.pushViewController(widget, animated: true)
    }

    private func startRoxchatSession() {
        RoxchatServiceController.shared.stopSession()
        let currentVisitorFieldsData = visitorFieldsManager.getVisitorData(for: .currentVisitor)
        _ = RoxchatServiceController.shared.createSession(jsonData: currentVisitorFieldsData)
        RoxchatServiceController.currentSession.set(unreadByVisitorMessageCountChangeListener: self)
        RoxchatServiceController.shared.fatalErrorHandlerDelegate = self
        unreadMessageCounter = RoxchatServiceController.currentSession.getUnreadMessagesByVisitor()
    }

}

// MARK: - Roxchat: MessageListener

extension WMStartViewController: UnreadByVisitorMessageCountChangeListener {

    // MARK: - Methods
    
    func changedUnreadByVisitorMessageCountTo(newValue: Int) {
        unreadMessageCounter = newValue
        updateMessageCounter()
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(newValue, withCompletionHandler: nil)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = newValue
        }
    }
}

// MARK: - FatalErrorHandler

extension WMStartViewController: FatalErrorHandlerDelegate {

    // MARK: - Methods
    
    func showErrorDialog(withMessage message: String) {
        alertDialogHandler.showCreatingSessionFailureDialog(withMessage: message)
        startChatButton.isHidden = true
    }

}
