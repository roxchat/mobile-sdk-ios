//
//  WMSelectAccountViewController.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import Foundation
import UIKit
import RoxchatClientLibrary

final class WMSelectAccountViewController: UIViewController {
    
    lazy var navigationBarUpdater = NavigationBarUpdater()
    lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var accountNameInfo: UIButton!
    @IBOutlet weak var invalidAccount: UILabel!
    @IBOutlet weak var continueButton: CustomButton!
    
    var isValid: Bool = false
    
    private lazy var visitorFieldsManager = WMVisitorFieldsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppVersion()
        updateNavigationBar()
        setupAppVersion()
        setupContinueButton()
        invalidAccount.isHidden = true
    }
    
    @IBAction func startSession(_ sender: Any) {
        continueWork()
    }
    
    @IBAction func showAlertForAccountName(_ sender: Any) {
        alertDialogHandler.showAlertForAccountName()
    }
    
    @objc func continueWork() {
        guard let accountName = accountName.text else {
            return
        }
        print("мы тут accountName")
        print(accountName)
        var url = accountName
        if !accountName.contains("https://") {
            url = "https://" + accountName + ".rox.chat"
        }
        print(url)
        let pingManager = RoxchatPingManager(serverURL: url)

        pingManager.sendPing { error in
            if error != nil {
                DispatchQueue.main.async {
                    print(error)
                    self.alertDialogHandler.showAlertForInvalidAccountName()
                }
            } else {
                DispatchQueue.main.async {
                    Settings.shared.saveAccountName(accountName: accountName)
                    let rootVC = WMStartViewController.loadViewControllerFromXib()
                    let navigationController = UINavigationController(rootViewController: rootVC)
                    AppDelegate.shared.window?.rootViewController = navigationController
                    if AppDelegate.shared.hasRemoteNotification {
                        rootVC.startChat(self)
                    }
                }
            }
        }
    }
    
    private func setupContinueButton() {
        continueButton.setTitleColor(saveButtonTitleColour, for: .normal)
        continueButton.setTitleColor(saveButtonTitleColour, for: .disabled)
        continueButton.isEnabled = false
        continueButton.layer.cornerRadius = 8.0
    }
    
    private func setupAppVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.appVersionLabel.text = "Application version".localized + ": v. " + version + "(" + buildNumber + ")"
        }
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        continueButton.isEnabled = accountName.text?.isEmpty == false
    }
    
    private func updateNavigationBar() {
        navigationBarUpdater.set(navigationController: self.navigationController)
        navigationBarUpdater.update(with: .defaultStyle)
        navigationBarUpdater.set(isNavigationBarVisible: true)
        let titleLabel = UILabel()
        titleLabel.text = "Settings".localized
        titleLabel.textColor = .white
        self.navigationItem.titleView = titleLabel
        let rightBarButton = UIButton()
        rightBarButton.addTarget(self, action: #selector(continueWork), for: .touchUpInside)
        rightBarButton.setTitle("Continue".localized, for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
    }
    
}
