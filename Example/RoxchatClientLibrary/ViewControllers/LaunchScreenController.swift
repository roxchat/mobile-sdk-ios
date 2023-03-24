
import UIKit

class LaunchScreenController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var progressBarView: UIProgressView!
    @IBOutlet var bottomTextLabel: UILabel!
    @IBOutlet var roxchatLogoImageView: UIImageView!
    
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
            },
            completion: { _ in
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
        )
    }
    
}
