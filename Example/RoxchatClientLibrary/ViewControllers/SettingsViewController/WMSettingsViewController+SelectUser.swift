//
//  WMSettingsViewController+SelectUser.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//


import UIKit
import RoxchatClientLibrary

extension WMSettingsViewController: SelectUserDelegate {
    func showUserList() {
        let vc = SelectVisitorViewController.loadViewControllerFromXib()
        vc.set(delegate: self)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension WMSettingsViewController: SelectVisitorDelegate {
    func didSelect(visitor: SelectVisitorViewController.VisitorRows) {
        var demoVisitor: DemoVisitor?
        switch visitor {
        case .unauthorized:
            demoVisitor = nil
        case .fedor:
            demoVisitor = .fedor
        case .semion:
            demoVisitor = .semion
        }
        
        visitorFieldsManager.set(selectedVisitor: demoVisitor)
        selectVisitorCell.usernameLabel.text = visitor.rawValue.localized
    }

}
