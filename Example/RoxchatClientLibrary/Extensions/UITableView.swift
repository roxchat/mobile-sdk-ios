//
//  UITableView.swift
//  RoxchatClientLibrary_Example
//
//  Created by Anna Frolova on 22.11.2023.
//  Copyright © 2023 Roxchat. All rights reserved.
//

import UIKit

extension UITableView {
    func scrollToRowSafe(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        if  indexPath.section >= 0 &&
            indexPath.row >= 0 &&
            self.numberOfSections > indexPath.section &&
            self.numberOfRows(inSection: indexPath.section) > indexPath.row {
            self.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
}
