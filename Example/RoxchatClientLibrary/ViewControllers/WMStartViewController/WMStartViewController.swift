
import UIKit
import RoxchatClientLibrary
import RoxChatMobileWidget

final class WMStartViewController: UIViewController {
    
    // MARK: - Private Properties
    private var unreadMessageCounter: Int = 0
    
    private lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    private lazy var visitorFieldsManager = WMVisitorFieldsManager()
    
    // MARK: - Outlets
    @IBOutlet var startChatButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var welcomeTextView: UITextView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var unreadMessageCounterView: UIView!
    @IBOutlet var unreadMessageCounterLabel: UILabel!
    @IBOutlet var unreadMessageCounterActivity: UIActivityIndicatorView!
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Workaround for displaying correctly the position of the text inside weclomeTextView
        DispatchQueue.main.async {
            self.welcomeTextView.setTextWithHyperLinks(self.welcomeTextView.text.localized)
            self.welcomeTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        }
        welcomeTextView.sizeToFit()
        setupColorScheme()
        updateNavigationBar()
        startRoxchatSession()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStartChatButton()
        setupSettingsButton()
        setupLogoTapGestureRecognizer()
        setupNavigationBarUpdater()
    }
    
    @IBAction func startChat(_ sender: Any? = nil) {
        presentChatViewController(
            openFromNotification: sender == nil,
            visitorData: visitorFieldsManager.getVisitorData(for: .currentVisitor)
        )
    }
    
    // MARK: - Private methods
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
    }

    @objc func presentWMLogsViewController(_ gesture: UIGestureRecognizer) {
        if WMTestManager.testModeEnabled() {
            let logsViewController = WMLogsViewController.loadViewControllerFromXib()
            navigationController?.pushViewController(logsViewController, animated: true)
        }
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
        
        settingsButton.layer.borderColor = settingButtonBorderColour
    }
    
    private func updateMessageCounter() {
        DispatchQueue.main.async {
            if self.unreadMessageCounter > 0 {
                self.unreadMessageCounterView.alpha = 1
                self.unreadMessageCounterLabel.text = "\(self.unreadMessageCounter)"
                self.unreadMessageCounterActivity.stopAnimating()
                self.unreadMessageCounterLabel.text = "\(self.unreadMessageCounter)"
            } else {
                self.unreadMessageCounterView.alpha = 0
            }
        }
    }
    
    private func presentChatViewController(openFromNotification: Bool, visitorData: Data? = nil) {
       RoxchatServiceController.currentSession.stopSession()
        
        let widget = ExternalWidgetBuilder().buildDefaultWidget(
            remoteNotificationSystem: .apns,
            visitorFieldsData: visitorData,
            roxchatLogger: WidgetLogManager.shared,
            roxchatLoggerVerbosityLevel: .debug,
            availableLogTypes: [.manualCall,.messageHistory,.networkRequest,.undefined],
            openFromNotification: openFromNotification
        )
        
        self.navigationController?.pushViewController(widget, animated: true)
    }
    
    private func startRoxchatSession() {
        RoxchatServiceController.currentSession.set(unreadByVisitorMessageCountChangeListener: self)
        RoxchatServiceController.shared.fatalErrorHandlerDelegate = self
        unreadMessageCounter = RoxchatServiceController.currentSession.getUnreadMessagesByVisitor()
        updateMessageCounter()
    }

    private func setupNavigationBarUpdater() {
        NavigationBarUpdater.shared.set(navigationController: navigationController) 
    }

    private func updateNavigationBar() {
        NavigationBarUpdater.shared.set(isNavigationBarVisible: false)
    }
    
    @IBAction func openSettings() {
        let settingsVc = WMSettingsViewController.loadViewControllerFromXib()
        navigationController?.pushViewController(settingsVc, animated: true)
    }
}

extension WMStartViewController: UnreadByVisitorMessageCountChangeListener {
    
    // MARK: - Methods
    func changedUnreadByVisitorMessageCountTo(newValue: Int) {
        if unreadMessageCounter == 0 {
            DispatchQueue.main.async {
                self.unreadMessageCounterActivity.stopAnimating()
            }
        }
        unreadMessageCounter = newValue
        updateMessageCounter()
    }
    
}

extension WMStartViewController: FatalErrorHandlerDelegate {
    
    // MARK: - Methods
    func showErrorDialog(withMessage message: String) {
        alertDialogHandler.showCreatingSessionFailureDialog(withMessage: message)
        startChatButton.isHidden = true
    }
    
}
