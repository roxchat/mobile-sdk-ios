
import Foundation
import RoxchatClientLibrary

class RoxchatServerSideSettingsManager {

    private var roxchatServerSideSettings: RoxchatServerSideSettings?

    func getServerSideSettings() {
        RoxchatServiceController.currentSession.getServerSideSettings(completionHandler: self)
    }

    func isGlobalReplyEnabled() -> Bool {
        guard let isGlobalReplyEnabled = roxchatServerSideSettings?.accountConfig.webAndMobileQuoting else {
            return false
        }
        return isGlobalReplyEnabled
    }

    func isMessageEditEnabled() -> Bool {
        guard let isMessageEditEnabled = roxchatServerSideSettings?.accountConfig.visitorMessageEditing else {
            return false
        }
        return isMessageEditEnabled
    }
}

extension RoxchatServerSideSettingsManager: ServerSideSettingsCompletionHandler {
    func onSuccess(roxchatServerSideSettings: RoxchatServerSideSettings) {
        self.roxchatServerSideSettings = roxchatServerSideSettings
    }

    func onFailure() {

    }

}
