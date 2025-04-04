//
//  Untitled.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import RoxchatClientLibrary

// MARK: - FatalErrorHandlerDelegate

protocol FatalErrorHandlerDelegate: AnyObject {
    
    // MARK: - Methods
    
    func showErrorDialog(withMessage message: String)
    
}

// MARK: - DepartmentListHandlerDelegate

protocol DepartmentListHandlerDelegate: AnyObject {
    
    // MARK: - Methods
    
    func showDepartmentsList(
        _ departaments: [Department],
        action: @escaping (String) -> Void
    )
}

extension DepartmentListHandlerDelegate {
    
    func showDepartmentsList(_ departmentList: [Department], action: @escaping (String) -> Void) {}
}
