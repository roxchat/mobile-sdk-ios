//
//  SelectVisitorTableViewCell.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import UIKit

protocol SelectUserDelegate: AnyObject {
    func showUserList()
}

class SelectVisitorTableViewCell: UITableViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var accessoryImageView: UIImageView!
    
    weak var delegate: SelectUserDelegate?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            delegate?.showUserList()
        }
    }
}
