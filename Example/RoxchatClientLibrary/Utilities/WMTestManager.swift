
import UIKit
import RoxchatClientLibrary

enum WMTestDialogAction {
    case sendMessage
    case editMessage
    case deleteMessage
    case replyToMessage
    case sendTyping
    case sendRandomImage
    case sendRandomFile
    case reactToMessage
    case noActinon
}

class WMTestManager: NSObject {
    static let testDialogActionsArray = createTestDialogActionsArray()
    private static let userDefaultsTestModeEnabledKey = WMKeychainWrapper.roxchatKeyPrefix + "userDefaultsTestModeEnabledKey"
    
    static func toogleTestMode() -> Bool {
        let boolValue = !UserDefaults.standard.bool(forKey: userDefaultsTestModeEnabledKey)
        UserDefaults.standard.set(boolValue, forKey: userDefaultsTestModeEnabledKey)
        return boolValue
    }
    
    static func testModeEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsTestModeEnabledKey)
    }
    
    private static func createTestDialogActionsArray() -> [WMTestDialogAction] {
        var testDialogActionsArray = [WMTestDialogAction]()
        testDialogActionsArray += Array(repeating: WMTestDialogAction.sendMessage, count: 10)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.editMessage, count: 10)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.deleteMessage, count: 5)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.replyToMessage, count: 10)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.sendTyping, count: 2)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.sendRandomImage, count: 3)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.sendRandomFile, count: 3)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.reactToMessage, count: 2)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.noActinon, count: 10)
        return testDialogActionsArray
    }
    
    static var testDialogModeEnabled = false
    static var testTimer: Timer?
}

extension ChatViewController {
    func runRandomAction() {
        if WMTestManager.testDialogModeEnabled {
            DispatchQueue.main.async {
                guard let message = self.randomMessage() else { return }
                
                switch WMTestManager.testDialogActionsArray.randomElement() {
                case .sendMessage:
                    self.sendMessage(self.randomMessageText())
                case .editMessage:
                    RoxchatServiceController.currentSession.edit(
                        message: message,
                        text: "edit" + self.randomMessageText(),
                        completionHandler: self
                    )
                case .deleteMessage:
                    RoxchatServiceController.currentSession.delete(
                        message: message,
                        completionHandler: self
                    )
                case .replyToMessage:
                    RoxchatServiceController.currentSession.reply(
                        message: self.randomMessageText(),
                        repliedMessage: message,
                        completion: { }
                    )
                case .sendTyping:
                    RoxchatServiceController.currentSession.setVisitorTyping(draft: "setVisitorTyping text")
                case .sendRandomImage:
                    self.sendRandomImage()
                case .sendRandomFile:
                    self.sendRandomFile()
                case .reactToMessage:
                    break
                case .noActinon:
                    break
                default:
                    break
                }
            }
        }
    }
    
    @objc func fireTestTimer() {
        runRandomAction()
    }
    
    func stopDialogTest() {
        WMTestManager.testTimer?.invalidate()
    }

    func sendRandomFile() {
        guard let file = "test file text".data(using: .utf8) else { return }
        RoxchatServiceController.currentSession.send(
            file: file,
            fileName: "testFile.txt",
            mimeType: "text/plain",
            completionHandler: self
        )
    }
    
    func replyToMessage() {
        guard let messageToReact = self.randomMessage() else { return }
        guard let reaction = [ReactionString.dislike, ReactionString.like].randomElement() else { return }
        
        RoxchatServiceController.currentSession.react(
            reaction: reaction,
            message: messageToReact,
            completionHandler: self
        )
    }

    private func sendRandomImage() {
        let image = UIImage(named: "AppIcon")
        let data = image!.jpegData(compressionQuality: 1.0)
        
        RoxchatServiceController.currentSession.send(
            file: data!,
            fileName: "testImage.jpg",
            mimeType: "image/jpeg",
            completionHandler: self
        )
    }

    func toggleAutotest() -> Bool {
        WMTestManager.testDialogModeEnabled.toggle()
        updateTestModeState()
        return WMTestManager.testDialogModeEnabled
    }
    
    func updateTestModeState() {
        if WMTestManager.testDialogModeEnabled {
            WMTestManager.testTimer = Timer.scheduledTimer(timeInterval: 1.1, target: self, selector: #selector(fireTestTimer), userInfo: nil, repeats: true)
        } else {
            WMTestManager.testTimer?.invalidate()
        }
    }

    private func randomMessageText() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy hh.mm.ss"
        return "test ios visitor " + formatter.string(from: date)
    }

    private func randomMessage() -> Message? {
        return self.messages().randomElement()
    }
}
