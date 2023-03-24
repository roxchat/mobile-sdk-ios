
import UIKit

protocol WMSurveyViewControllerDelegate: AnyObject {
    func sendSurveyAnswer(_ surveyAnswer: String)
    func surveyViewControllerClosed()
}

class WMSurveyViewController: UIViewController {

    weak var delegate: WMSurveyViewControllerDelegate?
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var transparentBackgroundView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        sendButton.layer.cornerRadius = 8
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(closeViewController))
        
        self.transparentBackgroundView?.addGestureRecognizer(touch)
    }
    
    @objc
    func closeViewController() {
        self.transparentBackgroundView?.alpha = 0
        dismiss(animated: true, completion: nil)
        self.delegate?.surveyViewControllerClosed()
    }
    
    @IBAction func close(_ sender: Any?) {
        self.closeViewController()
    }
    
    func disableSendButton() {
        self.sendButton.alpha = 0.5
        self.sendButton.isEnabled = false
    }
    
    func enableSendButton() {
        self.sendButton.alpha = 1
        self.sendButton.isEnabled = true
    }
}
