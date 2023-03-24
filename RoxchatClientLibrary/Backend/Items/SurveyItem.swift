
import Foundation

/**
 */
final class SurveyItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case config = "config"
        case currentQuestionInfo = "current_question"
        case id = "id"
    }
    
    // MARK: - Properties
    private var config: ConfigItem?
    private var currentQuesionInfo: CurrentQuestionInfoItem?
    private var id: String?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? String {
            self.id = id
        }
        
        if let config = jsonDictionary[JSONField.config.rawValue] as? [String: Any?] {
            self.config = ConfigItem(jsonDictionary: config)
        }
        
        if let currentQuestionInfo = jsonDictionary[JSONField.currentQuestionInfo.rawValue] as? [String: Any?] {
            self.currentQuesionInfo = CurrentQuestionInfoItem(jsonDictionary: currentQuestionInfo)
        }
    }
    
    // MARK: - Methods
    func getID() -> String? {
        return id
    }
    
    func getConfig() -> ConfigItem? {
        return config
    }
    
    func getCurrentQuestionInfo() -> CurrentQuestionInfoItem? {
        return currentQuesionInfo
    }
}

final class ConfigItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "id"
        case descriptor = "descriptor"
        case version = "version"
    }
    
    // MARK: - Properties
    private var id: Int?
    private var descriptor: DescriptorItem?
    private var version: String?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? Int {
            self.id = id
        }
        
        if let descriptor = jsonDictionary[JSONField.descriptor.rawValue] as? [String: Any?] {
            self.descriptor = DescriptorItem(jsonDictionary: descriptor)
        }
        
        if let version = jsonDictionary[JSONField.version.rawValue] as? String {
            self.version = version
        }
    }
    
    // MARK: - Methods
    func getID() -> Int? {
        return id
    }
    
    func getDescriptor() -> DescriptorItem? {
        return descriptor
    }
    
    func getVersion() -> String? {
        return version
    }
}

final class DescriptorItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case forms = "forms"
    }
    
    // MARK: - Properties
    private var forms: [FormItem]?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let formsValue = jsonDictionary[JSONField.forms.rawValue] as? [Any] {
            forms = []
            for form in formsValue {
                if let formValue = form as? [String: Any?] {
                    let formItem = FormItem(jsonDictionary: formValue)
                    forms?.append(formItem)
                }
            }
        }
    }
    
    // MARK: - Methods
    func getForms() -> [FormItem]? {
        return forms
    }
}

final class FormItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "id"
        case questions = "questions"
    }
    
    // MARK: - Properties
    private var id: Int?
    private var questions: [QuestionItem]?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? Int {
            self.id = id
        }
        if let questionsValue = jsonDictionary[JSONField.questions.rawValue] as? [Any] {
            questions = []
            for question in questionsValue {
                if let questionValue = question as? [String: Any?] {
                    let questionItem = QuestionItem(jsonDictionary: questionValue)
                    questions?.append(questionItem)
                }
            }
        }
    }
    
    // MARK: - Methods
    func getID() -> Int? {
        return id
    }
    
    func getQuestions() -> [QuestionItem]? {
        return questions
    }
}

final class QuestionItem {
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case type = "type"
        case text = "text"
        case options = "options"
    }
    
    // MARK: - Properties
    private var type: QuestionKind?
    private var text: String?
    private var options: [String]?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let type = jsonDictionary[JSONField.type.rawValue] as? String {
            self.type = QuestionKind(rawValue: type)
        }
        
        if let text = jsonDictionary[JSONField.text.rawValue] as? String {
            self.text = text
        }
        
        if let options = jsonDictionary[JSONField.options.rawValue] as? [String] {
            self.options = options
        }
    }
    
    func getType() -> QuestionKind? {
        return type
    }
    
    func getText() -> String? {
        return text
    }
    
    func getOptions() -> [String]? {
        return options
    }
    
    enum QuestionKind: String {
        case stars = "stars"
        case radio = "radio"
        case comment = "comment"
    }
}

final class CurrentQuestionInfoItem {
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case formID = "form_id"
        case questionID = "question_id"
    }
    
    // MARK: - Properties
    private var formID: Int?
    private var questionID: Int?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let formID = jsonDictionary[JSONField.formID.rawValue] as? Int {
            self.formID = formID
        }
        
        if let questionID = jsonDictionary[JSONField.questionID.rawValue] as? Int {
            self.questionID = questionID
        }
    }
    
    func getFormID() -> Int? {
        return formID
    }
    
    func getQuestionID() -> Int? {
        return questionID
    }
}
