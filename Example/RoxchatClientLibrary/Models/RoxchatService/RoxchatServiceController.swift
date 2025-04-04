
import UIKit
import RoxchatClientLibrary

class RoxchatServiceController {
    
    static let shared = RoxchatServiceController()
    
    static var currentSession: RoxchatService {
        return RoxchatServiceController.shared.currentSession()
    }
    
    static var currentSessionShare: RoxchatService {
        return RoxchatServiceController.shared.createSession()
    }
    
    weak var fatalErrorHandlerDelegate: FatalErrorHandlerDelegate?
    weak var departmentListHandlerDelegate: DepartmentListHandlerDelegate?
    weak var notFatalErrorHandler: NotFatalErrorHandler?
    
    private var roxchatService: RoxchatService?
    
    func createSession(jsonString: String? = nil, jsonData: Data? = nil) -> RoxchatService {
        
        stopSession()
        print("createSession")
        let service = RoxchatService(
            fatalErrorHandlerDelegate: self,
            departmentListHandlerDelegate: self,
            notFatalErrorHandler: self
        )
        
        service.createSession(jsonString: jsonString, jsonData: jsonData)
        service.resumeSession()
        service.setMessageStream()
        
        self.roxchatService = service
        return service
    }
    
    func setCurrentSession(_ session: RoxchatSession) {
        stopSession()
        print("createSession")
        let roxchatService = RoxchatService(
            fatalErrorHandlerDelegate: self,
            departmentListHandlerDelegate: self,
            notFatalErrorHandler: self
        )
        
        roxchatService.set(session: session)
        roxchatService.resumeSession()
        roxchatService.setMessageStream()
        
        self.roxchatService = roxchatService
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
