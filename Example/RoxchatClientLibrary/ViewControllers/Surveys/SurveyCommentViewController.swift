
import AVFoundation
import UIKit

class SurveyCommentViewController: WMSurveyViewController {
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var commentTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var commentTextView: TextViewWithPlaceholder!
    
    var descriptionText: String?
    var commentMessage: String?

    @IBOutlet var contentViewWidthConstraint: NSLayoutConstraint?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentTextView.setPlaceholder("Enter your comment".localized, placeholderColor: WMSurveyCommentPlaceholderColor)
        self.setupSubviews()
        self.hideKeyboardOnTap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        self.textViewDidChange(self.commentTextView)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        self.textViewDidChange(self.commentTextView)
    }

    func fixContentViewWidth() {
        self.contentViewWidthConstraint?.constant = WMInterfaceData.shared.screenWidth()
    }
    
    func checkHeightConstraints() {
        fixContentViewWidth()
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            
            let contentHeight = self.recountContentViewHeight()
            var greyViewHeight = max(WMInterfaceData.shared.screenHeight() - contentHeight, 0)
            if greyViewHeight < 100 {
                if WMInterfaceData.shared.screenHeight() < 450 {
                    greyViewHeight = 0
                } else {
                    greyViewHeight = 100
                }
            }
            var frame = self.scrollView.frame
            frame.origin.x = 0
            frame.origin.y = greyViewHeight
            frame.size.height = WMInterfaceData.shared.screenHeight() - greyViewHeight
            frame.size.width = WMInterfaceData.shared.screenWidth()
            self.scrollView.frame = frame
        }
        
    }
    
    @objc
    func rotated() {
        textViewDidChange(self.commentTextView)
        
        var testRect = self.commentLabel.frame
        testRect.origin.y -= 5
        testRect.size.height = self.view.frame.height
        scrollView?.scrollRectToVisible(testRect, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.commentTextView.becomeFirstResponder()
    }
    
    @IBAction private func send(_ sender: Any) {
        
        self.delegate?.sendSurveyAnswer(commentTextView.text ?? "")
        self.closeViewController()
    }
    
    private func setupSubviews() {
        descriptionLabel.text = descriptionText
    }
    func recountContentViewHeight() -> CGFloat {
        
        var contentViewHeight = self.contentView.frame.height - self.commentTextView.frame.height + WMInterfaceData.shared.keyboardHeight()
        let textViewHeight = commentTextView.sizeThatFits(CGSize(width: commentTextView.frame.width, height: CGFloat(MAXFLOAT))).height
        commentTextViewHeightConstraint.constant = textViewHeight
        contentViewHeight += textViewHeight
        scrollView.contentSize = CGSize(width: 320, height: contentViewHeight)
        return contentViewHeight
    }
}

extension SurveyCommentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.commentTextView.textViewDidChange()
        checkHeightConstraints()
    }
    
}
