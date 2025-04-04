
import UIKit
import RoxchatClientLibrary

class LaunchScreenController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var progressBarView: UIProgressView!
    @IBOutlet var bottomTextLabel: UILabel!
    @IBOutlet var roxchatLogoImageView: UIImageView!
    @IBOutlet var appVersion: UILabel!
    
    // MARK: - Properties
    
    private let progress = Progress(totalUnitCount: 100)
    private var timer = Timer()
    
    // MARK: - View Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.02,
            target: self,
            selector: #selector(updateProgressBar),
            userInfo: nil,
            repeats: true
        )
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersion.text = "v. " + version
        }
        animateView()
    }
    
    // MARK: - Private methods
    @objc
    private func updateProgressBar(timer: Timer) {
        guard !self.progress.isFinished else {
            timer.invalidate()
            return
        }
        
        self.progress.completedUnitCount += 1
        self.progressBarView.setProgress(
            Float(self.progress.fractionCompleted),
            animated: true
        )
    }

    private func animateView() {
        UIView.animate(
            withDuration: 1,
            delay: 2.0,
            animations: {
                self.progressBarView.alpha = 0
                self.roxchatLogoImageView.alpha = 0
                self.bottomTextLabel.alpha = 0
                self.appVersion.alpha = 0
            },
            completion: { _ in
                if Settings.shared.getAccountName() == "" {
                    let rootVC = WMLoginViewController.loadViewControllerFromXib()
                    let navigationController = UINavigationController(rootViewController: rootVC)
                    AppDelegate.shared.window?.rootViewController = navigationController
                } else {
                    let rootVC = WMStartViewController.loadViewControllerFromXib()
                    let navigationController = UINavigationController(rootViewController: rootVC)
                    AppDelegate.shared.window?.rootViewController = navigationController
                    if AppDelegate.shared.hasRemoteNotification {
                        rootVC.startChat(self)
                    }
                }
            }
        )
    }
    
}
