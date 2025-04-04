//
//  CustomButton.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override public var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
            } else {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.4)
            }
        }
    }

}
