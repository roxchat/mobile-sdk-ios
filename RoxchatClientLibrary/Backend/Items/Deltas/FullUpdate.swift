
import Foundation

/**
 Class that encapsulates full data update, received from a server.
 */
struct FullUpdate {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case authorizationToken = "authToken"
        case chat = "chat"
        case departments = "departments"
        case hintsEnabled = "hintsEnabled"
        case historyRevision = "historyRevision"
        case onlineStatus = "onlineStatus"
        case pageID = "pageId"
        case sessionID = "visitSessionId"
        case state = "state"
        case survey = "survey"
        case visitor = "visitor"
        case showHelloMessage = "showHelloMessage"
        case chatStartAfterMessage = "chatStartAfterMessage"
        case helloMessageDescr = "helloMessageDescr"
    }
    
    // MARK: - Properties
    private var authorizationToken: String?
    private var chat: ChatItem?
    private var departments: [DepartmentItem]?
    private var hintsEnabled: Bool
    private var historyRevision: Int?
    private var onlineStatus: String?
    private var pageID: String?
    private var sessionID: String?
    private var state: String?
    private var survey: SurveyItem?
    private var visitorJSONString: String?
    private var showHelloMessage: Bool?
    private var chatStartAfterMessage: Bool?
    private var helloMessageDescr: String?

    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let authorizationToken = jsonDictionary[JSONField.authorizationToken.rawValue] as? String {
            self.authorizationToken = authorizationToken
        }
        
        if let showHelloMessage = jsonDictionary[JSONField.showHelloMessage.rawValue] as? Bool {
            self.showHelloMessage = showHelloMessage
        }
        
        if let chatStartAfterMessage = jsonDictionary[JSONField.chatStartAfterMessage.rawValue] as? Bool {
            self.chatStartAfterMessage = chatStartAfterMessage
        }
        
        if let helloMessageDescr = jsonDictionary[JSONField.helloMessageDescr.rawValue] as? String {
            self.helloMessageDescr = helloMessageDescr
        }
        
        if let chatValue = jsonDictionary[JSONField.chat.rawValue] as? [String: Any?] {
            chat = ChatItem(jsonDictionary: chatValue)
        }
        
        if let pageID = jsonDictionary[JSONField.pageID.rawValue] as? String {
            self.pageID = pageID
        }
        
        if let onlineStatus = jsonDictionary[JSONField.onlineStatus.rawValue] as? String {
            self.onlineStatus = onlineStatus
        }
        
        if let sessionID = jsonDictionary[JSONField.sessionID.rawValue] as? String {
            self.sessionID = sessionID
        }
        
        if let state = jsonDictionary[JSONField.state.rawValue] as? String {
            self.state = state
        }
        
        if let visitorJSON = jsonDictionary[JSONField.visitor.rawValue] {
            if let visitorJSONData = try? JSONSerialization.data(withJSONObject: visitorJSON as Any) {
                visitorJSONString = String(data: visitorJSONData,
                                           encoding: .utf8)
            }
        }
        
        if let departmantsData = jsonDictionary[JSONField.departments.rawValue] as? [Any] {
            var departmentItems = [DepartmentItem]()
            for departmentData in departmantsData {
                if let departmentDictionary = departmentData as? [String: Any] {
                    if let deparmentItem = DepartmentItem(jsonDictionary: departmentDictionary) {
                        departmentItems.append(deparmentItem)
                    }
                }
            }
            self.departments = departmentItems
        }
        
        hintsEnabled = (jsonDictionary[JSONField.hintsEnabled.rawValue] as? Bool) ?? false
        
        if let historyRevision = jsonDictionary[JSONField.historyRevision.rawValue] as? Int {
            self.historyRevision = historyRevision
        }
        
        if let surveyValue = jsonDictionary[JSONField.survey.rawValue] as? [String: Any?] {
            self.survey = SurveyItem(jsonDictionary: surveyValue)
        }
    }
    
    // MARK: - Methods
    
    func getShowHelloMessage() -> Bool? {
        return showHelloMessage
    }
    
    func getChatStartAfterMessage() -> Bool? {
        return chatStartAfterMessage
    }
    
    func getHelloMessageDescr() -> String? {
        return helloMessageDescr
    }
    
    func getAuthorizationToken() -> String? {
        return authorizationToken
    }
    
    func getDepartments() -> [DepartmentItem]? {
        return departments
    }
    
    func getChat() -> ChatItem? {
        return chat
    }
    
    func getHintsEnabled() -> Bool {
        return hintsEnabled
    }
    
    func getHistoryRevision() -> String? {
        guard let historyRevision = historyRevision else {
            return nil
        }
        return String(historyRevision)
    }
    
    func getOnlineStatus() -> String? {
        return onlineStatus
    }
    
    func getPageID() -> String? {
        return pageID
    }
    
    func getSessionID() -> String? {
        return sessionID
    }
    
    func getState() -> String? {
        return state
    }
    
    func getSurvey() -> SurveyItem? {
        return survey
    }
    
    func getVisitorJSONString() -> String? {
        return visitorJSONString
    }
    
}
