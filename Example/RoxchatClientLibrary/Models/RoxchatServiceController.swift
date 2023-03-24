
import UIKit
import RoxchatClientLibrary

class RoxchatServiceController {
    
    static let shared = RoxchatServiceController()
    
    private var roxchatService: RoxchatService?
    
    weak var fatalErrorHandlerDelegate: FatalErrorHandlerDelegate?
    weak var departmentListHandlerDelegate: DepartmentListHandlerDelegate?
    weak var notFatalErrorHandler: NotFatalErrorHandler?
    
    func createSession() -> RoxchatService {
        
        stopSession()
        print("createSession")
        let service = RoxchatService(
            fatalErrorHandlerDelegate: self,
            departmentListHandlerDelegate: self,
            notFatalErrorHandler: self
        )
        
        service.createSession()
        service.startSession()
        service.setMessageStream()
        
        self.roxchatService = service
        return service
    }
    
    static var currentSession: RoxchatService {
        return RoxchatServiceController.shared.currentSession()
    }
    
    func currentSession() -> RoxchatService {
        return self.roxchatService ?? createSession()
    }
    
    func stopSession() {
        print("stopSession")
        self.roxchatService?.stopSession()
        self.roxchatService = nil
    }
    
    func sessionState() -> ChatState {
        return roxchatService?.sessionState() ?? .unknown
    }
}

extension RoxchatServiceController: FatalErrorHandlerDelegate {
    
    func showErrorDialog(withMessage message: String) {
        self.fatalErrorHandlerDelegate?.showErrorDialog(withMessage: message)
    }
}

extension RoxchatServiceController: DepartmentListHandlerDelegate {
    
    func showDepartmentsList(_ departaments: [Department], action: @escaping (String) -> Void ) {
        self.departmentListHandlerDelegate?.showDepartmentsList(departaments, action: action)
    }
}

extension RoxchatServiceController: NotFatalErrorHandler {
    
    func on(error: RoxchatNotFatalError) {
        self.notFatalErrorHandler?.on(error: error)
    }
    
    func connectionStateChanged(connected: Bool) {
        self.notFatalErrorHandler?.connectionStateChanged(connected: connected)
    }
}
