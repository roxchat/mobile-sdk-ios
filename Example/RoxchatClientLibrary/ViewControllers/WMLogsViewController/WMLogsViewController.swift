
import UIKit
import RoxChatMobileWidget

class WMLogsViewController: UIViewController {
    
    lazy var navigationBarUpdater = NavigationBarUpdater()

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        setupScrollButtonImage()
    }

    @IBAction private func scrollToBottom() {
        if !textView.text.isEmpty {
            let location = textView.text.count - 1
            let bottom = NSRange(location: location, length: 1)
            textView.scrollRangeToVisible(bottom)
        }
    }

    private func setupTextView() {
        let logs = WidgetLogManager.shared.getLogs()
        logs.forEach { log in
            addLog(log)
        }
    }

    private func addLog(_ log: String) {
        textView.text.append("\(log) \n \n")
    }

    private func setupScrollButtonImage() {
        scrollButton.setTitle(nil, for: .normal)
        scrollButton.setBackgroundImage(scrollButtonImage, for: .normal)
    }

    private func updateNavigationBar() {
        navigationBarUpdater.set(navigationController: navigationController)
        navigationBarUpdater.set(isNavigationBarVisible: true)
        navigationBarUpdater.update(with: .defaultStyle)
    }
}

extension WMLogsViewController: WidgetLogManagerObserver {
    func didGetNewLog(log: String) {
        addLog(log)
        print(log)
    }
}
