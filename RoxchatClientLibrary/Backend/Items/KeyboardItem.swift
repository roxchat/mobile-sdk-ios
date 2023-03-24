
import Foundation

/**
 */
struct KeyboardItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case buttons = "buttons"
        case state = "state"
        case response = "response"
    }
    
    // MARK: - Properties
    private let buttons: [[KeyboardButtonItem]]
    var state: KeyboardState
    private var response: KeyboardResponseItem?
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        if let data = jsonDictionary[JSONField.buttons.rawValue] as? [[[String: Any?]]] {
            var buttonArrayArray = [[KeyboardButtonItem]]()
            for buttonArray in data {
                var newButtonArray = [KeyboardButtonItem]()
                for button in buttonArray {
                    guard let buttonItem = KeyboardButtonItem(jsonDictionary: button) else {
                        RoxchatInternalLogger.shared.log(entry: "Getting KeyboardButtonItem from json failure in KeyboardItem.\(#function)")
                        return nil
                    }
                    newButtonArray.append(buttonItem)
                }
                buttonArrayArray.append(newButtonArray)
            }
            self.buttons = buttonArrayArray
        } else {
            return nil
        }
        
        if let state = jsonDictionary[JSONField.state.rawValue] as? String {
            switch state {
            case "pending":
                self.state = .pending
            case "completed":
                self.state = .completed
            default:
                self.state = .canceled
            }
        } else {
            return nil
        }
        
        if let response = jsonDictionary[JSONField.response.rawValue] as? [String: Any?] {
            self.response = KeyboardResponseItem(jsonDictionary: response)
        }
    }
    
    // MARK: - Methods
    
    func getButtons() -> [[KeyboardButtonItem]] {
        return buttons
    }
    
    func getState() -> KeyboardState {
        return state
    }
    
    func getResponse() -> KeyboardResponseItem? {
        return response
    }
}

/**
 */
struct KeyboardButtonItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "id"
        case text = "text"
        case config = "config"
    }
    
    // MARK: - Properties
    private let id: String?
    private let text: String?
    private var config: ConfigurationItem?
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? String {
            self.id = id
        } else {
            return nil
        }
        
        if let text = jsonDictionary[JSONField.text.rawValue] as? String {
            self.text = text
        } else {
            return nil
        }
        
        if let config = jsonDictionary[JSONField.config.rawValue] as? [String: Any?] {
            self.config = ConfigurationItem(jsonDictionary: config)
        }
    }
    
    // MARK: - Methods
    
    func getId() -> String {
        guard let id = id else {
            RoxchatInternalLogger.shared.log(entry: "ID is nil in KeyboardButtonItem.\(#function)")
            return String()
        }
        return id
    }
    
    func getText() -> String {
        guard let text = text else {
            RoxchatInternalLogger.shared.log(entry: "Text is nil in KeyboardButtonItem.\(#function)")
            return String()
        }
        return text
    }
    
    func getConfiguration() -> ConfigurationItem? {
        return config
    }
    
}

/**
 */
struct KeyboardResponseItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case buttonId = "buttonId"
        case messageId = "messageId"
    }
    
    // MARK: - Properties
    private let messageId: String?
    private let buttonId: String?
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        if let buttonId = jsonDictionary[JSONField.buttonId.rawValue] as? String {
            self.buttonId = buttonId
        } else {
            return nil
        }
        
        if let messageId = jsonDictionary[JSONField.messageId.rawValue] as? String {
            self.messageId = messageId
        } else {
            return nil
        }
    }
    
    // MARK: - Methods
    
    func getMessageId() -> String {
        guard let messageId = messageId else {
            RoxchatInternalLogger.shared.log(entry: "Message ID is nil in KeyboardResponseItem.\(#function)")
            return String()
        }
        return messageId
    }
    
    func getButtonId() -> String {
        guard let buttonId = buttonId else {
            RoxchatInternalLogger.shared.log(entry: "Button ID is nil in KeyboardResponseItem.\(#function)")
            return String()
        }
        return buttonId
    }
}

/**
 */
struct KeyboardRequestItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case button = "button"
        case messageId = "messageId"
        case request = "request"
    }
    
    // MARK: - Properties
    private let button: KeyboardButtonItem?
    private let messageId: String?
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        if let button = jsonDictionary[JSONField.button.rawValue] as? [String: Any?] {
            self.button = KeyboardButtonItem(jsonDictionary: button)
        } else {
            return nil
        }
        
        if let request = jsonDictionary[JSONField.request.rawValue] as? [String: Any?],
            let messageId = request[JSONField.messageId.rawValue] as? String {
            self.messageId = messageId
        } else {
            return nil
        }
    }
    
    // MARK: - Methods
    
    func getMessageId() -> String {
        guard let messageId = messageId else {
            RoxchatInternalLogger.shared.log(entry: "Message ID is nil in KeyboardRequestItem.\(#function)")
            return String()
        }
        return messageId
    }
    
    func getButton() -> KeyboardButtonItem {
        guard let button = button else {
            RoxchatInternalLogger.shared.log(entry: "Button is nil in KeyboardRequestItem.\(#function)")
            fatalError("Button is nil in KeyboardRequestItem.\(#function)")
        }
        return button
    }
}

/**
 */
struct ConfigurationItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case active = "active"
        case link = "link"
        case textToInsert = "text_to_insert"
        case state = "state"
    }
    
    // MARK: - Properties
    private var active: Bool
    private var data: String
    private var state: ButtonState
    private var type: ButtonType
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        if let active = jsonDictionary[JSONField.active.rawValue] as? Bool {
            self.active = active
        } else {
            return nil
        }
        
        if let data = jsonDictionary[JSONField.link.rawValue] as? String {
            self.data = data
            self.type = ButtonType.url
        } else if let data = jsonDictionary[JSONField.textToInsert.rawValue] as? String {
            self.data = data
            self.type = ButtonType.insert
        } else {
            return nil
        }
        
        if let state = jsonDictionary[JSONField.state.rawValue] as? String {
            switch state {
            case "showing":
                self.state = .showing
                
                break
            case "showing_selected":
                self.state = .showingSelected
                
                break
            default:
                self.state = .hidden
            }
        } else {
            return nil
        }
    }
    
    // MARK: - Methods
    
    func isActive() -> Bool {
        return active
    }
    
    func getData() -> String {
        return data
    }
    
    func getState() -> ButtonState {
        return state
    }
    
    func getButtonType() -> ButtonType {
        return type
    }
    
}
