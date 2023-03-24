
import UIKit
import RoxchatClientLibrary

protocol RoxchatLogManagerObserver {
    func didGetNewLog(log: String)
}

class WMLogsViewController: UIViewController {


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
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }

    private func setupTextView() {
        let logs = RoxchatLogManager.shared.getLogs()
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
        NavigationBarUpdater.shared.set(isNavigationBarVisible: true)
        NavigationBarUpdater.shared.update(with: .defaultStyle)
    }
}

extension WMLogsViewController: RoxchatLogManagerObserver {
    func didGetNewLog(log: String) {
        addLog(log)
        print(log)
    }
}
