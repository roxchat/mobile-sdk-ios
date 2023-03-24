
import UIKit
import WebKit
import SnapKit
import CloudKit
import CoreServices

class WMFileViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // MARK: - Properties
    var fileDestinationURL: URL?
    
    // MARK: - Private properties
    private var contentWebView = WKWebView()
    
    private lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    
    // MARK: - Outlets
    @IBOutlet var contentWebViewContainer: UIView!
    @IBOutlet var loadingStatusLabel: UILabel!
    @IBOutlet var loadingStatusIndicator: UIActivityIndicatorView!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        setupLoadingSubiews()
        setupContentWebView()
        loadData()
    }
    
    
    @IBAction func saveFile(_ sender: Any) {
        guard let fileToSave = fileDestinationURL else { return }
        let ac = UIActivityViewController(activityItems: [fileToSave], applicationActivities: nil)
        self.present(ac, animated: true)
        ac.completionWithItemsHandler = { type, bool, _, error in
            if bool && (type == .saveToCameraRoll || type == .saveToFile) {
                let saveView = WMSaveView.loadXibView()
                self.view.addSubview(saveView)
                saveView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                saveView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                self.view.bringSubviewToFront(saveView)
                saveView.animateImage()
            }
            if let error = error {
                self.alertDialogHandler.showFileSavingFailureDialog(withError: error)
            }
        }
    }
    
    // MARK: - WKWebView methods
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == "estimatedProgress",
            contentWebView.estimatedProgress == 1.0
            else { return }
        
        loadingStatusLabel.isHidden = true
        loadingStatusIndicator.stopAnimating()
        loadingStatusIndicator.isHidden = true
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard navigationAction.navigationType == .linkActivated,
            let url = navigationAction.request.url,
            UIApplication.shared.canOpenURL(url) else {
            decisionHandler(.allow)
            return
        }
        
        UIApplication.shared.open(url)
        decisionHandler(.cancel)
    }

    // MARK: - Private methods
    private func setupNavigationItem() {
        /// Files App was presented in iOS 11.0
        guard #available(iOS 11.0, *) else { return }

        let rightButton = UIButton(type: .system)
        rightButton.frame = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
        rightButton.setBackgroundImage(saveImageButtonImage, for: .normal)
        rightButton.addTarget(
            self,
            action: #selector(saveFile),
            for: .touchUpInside
        )
        
        rightButton.snp.remakeConstraints { (make) -> Void in
            make.height.width.equalTo(25.0)
        }
        
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func setupLoadingSubiews() {
        loadingStatusLabel.text = "Loading File...".localized
        loadingStatusIndicator.startAnimating()
    }
    
    /// Workaround for iOS < 11.0
    private func setupContentWebView() {
        contentWebView.navigationDelegate = self
        contentWebView.allowsLinkPreview = true
        contentWebView.uiDelegate = self
        contentWebView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
        
        contentWebViewContainer.addSubview(contentWebView)
        contentWebViewContainer.sendSubviewToBack(contentWebView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        contentWebView.translatesAutoresizingMaskIntoConstraints = false
        contentWebView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    private func loadData() {
        guard let destinationURL = fileDestinationURL else { return }
        contentWebView.load(URLRequest(url: destinationURL))
    }
}

