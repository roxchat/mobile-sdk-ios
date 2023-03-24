
import Foundation
import UIKit
import RoxchatClientLibrary

protocol ChatTestViewDelegate: UIViewController {
    func getSearchMessageText() -> String
    func showSearchResult(searcMessages: [Message]?)
    func toogleAutotest() -> Bool
    func clearHistory()
}

class ChatTestView: UIView {
    @IBOutlet var autotestButton: UIButton!
    @IBOutlet var clearHistory: UIButton!
    @IBOutlet var operatorInfo: UIButton!
    private weak var delegate: ChatTestViewDelegate!
    private var titleViewOperatorTitle: String?
    private var titleViewOperatorInfo: String?
    
    override func loadXibViewSetup() {
        clearHistory.setImage(deleteImage, for: .normal)
    }
    
    func setupView(delegate: ChatTestViewDelegate) {
        self.delegate = delegate
    }
    
    func setupOperatorInfo(titleViewOperatorTitle: String?, titleViewOperatorInfo: String?) {
        self.titleViewOperatorInfo = titleViewOperatorInfo
        self.titleViewOperatorTitle = titleViewOperatorTitle
    }
    
    @IBAction func runAutotestClicked() {
        let autotestRunning = self.delegate.toogleAutotest()
        self.autotestButton.setTitle(autotestRunning ? "Stop autotest" : "Run autotest", for: .normal)
    }
    
    @IBAction func hideTap() {
        self.alpha = 0
    }
    
    @IBAction func searchTap() {
        let searchText = self.delegate.getSearchMessageText()
        if searchText.isEmpty {
            self.delegate.showSearchResult(searcMessages: nil)
        } else {
            RoxchatServiceController.shared.currentSession().searchMessagesBy(query: searchText, completionHandler: self)
        }
    }
    
    @IBAction func clearHistoryTap(_ sender: Any) {
        let alert = UIAlertController(title: "Clean history",
                                      message: "Clean history",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
                RoxchatServiceController.currentSession.clearHistory()
                self.delegate.clearHistory()
            }
        )
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )
        let actions = [okAction, cancelAction]
        actions.forEach({ alert.addAction($0) })
        self.delegate.present(alert, animated: true)
    }
    
    @IBAction func operatorInfotap(_ sender: Any) {
        let alertDialogHandler = UIAlertHandler(delegate: delegate)
        let operatorTitle = titleViewOperatorTitle ?? ""
        let operatorInfo = titleViewOperatorInfo ?? ""
        alertDialogHandler.showOperatorInfo(
            withMessage: "\("Agent title".localized): \(operatorTitle.description) \n \("Additional information".localized): \(operatorInfo.description) "
        )
    }
    
}

extension ChatTestView: SearchMessagesCompletionHandler {
    
    func onSearchMessageSuccess(query: String, messages: [Message]) {
        self.delegate.showSearchResult(searcMessages: messages)
        print(messages)
    }
    
    func onSearchMessageFailure(query: String) {
        self.delegate.showSearchResult(searcMessages: [])
        print("onSearchMessageFailure")
    }
    
}
