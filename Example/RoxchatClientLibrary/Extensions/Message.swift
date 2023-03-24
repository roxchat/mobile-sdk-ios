
import Foundation
import RoxchatClientLibrary

extension Message {
    
    // MARK: - Methods
    public func isSystemType() -> Bool {
        return self.getType() == .actionRequest
            || self.getType() == .contactInformationRequest
            || self.getType() == .info
            || self.getType() == .keyboard
            || self.getType() == .keyboardResponse
            || self.getType() == .operatorBusy
    }
    
    public func isVisitorType() -> Bool {
        return self.getType() == .visitorMessage
            || self.getType() == .fileFromVisitor
    }
    
    public func isOperatorType() -> Bool {
        return self.getType() == .operatorMessage
            || self.getType() == .fileFromOperator
    }
    
    public func canBeCopied() -> Bool {
        return self.getType() == .operatorMessage
            || self.getType() == .visitorMessage
    }
    
    func isFile() -> Bool {
        return self.getType() == .fileFromOperator
            || self.getType() == .fileFromVisitor
    }
    
    func isText() -> Bool {
        return self.getType() == .operatorMessage
            || self.getType() == .visitorMessage
    }
    
}
