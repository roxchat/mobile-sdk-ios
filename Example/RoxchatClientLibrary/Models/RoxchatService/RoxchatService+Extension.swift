//
//  RoxchatService+Extension.swift
//  RoxchatClientLibrary_Example
//
//  Copyright © 2025 Roxchat. All rights reserved.
//

import RoxchatClientLibrary

// MARK: - ROXCHAT: FatalErrorHandler

extension RoxchatService: FatalErrorHandler {
    
    // MARK: - Methods
    
    func on(error: RoxchatError) {
        let errorType = error.getErrorType()
        switch errorType {
        case .accountBlocked:
            // Assuming to contact with Roxchat support.
            print("Account with used account name is blocked by Roxchat service.")
            fatalErrorHandlerDelegate?.showErrorDialog(withMessage: "AccountBlocked".localized)
            
        case .providedVisitorFieldsExpired:
            // Assuming to re-authorize it and re-create session object.
            print("Provided visitor fields expired. See \"expires\" key of this fields.")
            
        case .unknown:
            print("An unknown error occured: \(error.getErrorString()).")
            
        case .visitorBanned:
            print("Visitor with provided visitor fields is banned by an operator.")
            fatalErrorHandlerDelegate?.showErrorDialog(withMessage: "Your visitor account is in the black list.".localized)
            
        case .wrongProvidedVisitorHash:
            // Assuming to check visitor field generating.
            print("Wrong CRC passed with visitor fields.")
            
        case .initializationFailed:
            print("Session initialization failed.")
            fatalErrorHandlerDelegate?.showErrorDialog(withMessage: "Session initialization failed.".localized)
        }
    }
    
}

// MARK: - ROXCHAT: NotFatalErrorHandler

extension RoxchatService: NotFatalErrorHandler {
    
    func on(error: RoxchatNotFatalError) {
        self.notFatalErrorHandler?.on(error: error)
    }
    
    func connectionStateChanged(connected: Bool) {
        self.notFatalErrorHandler?.connectionStateChanged(connected: connected)
    }
    
}
