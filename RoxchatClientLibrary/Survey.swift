
import Foundation

/**
 Abstracts a survey.
 */
public protocol Survey {
    /**
     - returns:
     Config of the survey.
     */
    func getConfig() -> SurveyConfig
    
    /**
     Every survey can be uniquefied by its ID.
     - returns:
     Unique ID of the survey.
     */
    func getID() -> String
    
    /**
     - returns:
     Current question information of the survey.
     */
    func getCurrentQuestionInfo() -> SurveyCurrentQuestionInfo
}

/**
Abstracts a survey config.
*/
public protocol SurveyConfig {
    /**
     - returns:
     Unique ID of the survey config.
     */
    func getID() -> Int

    /**
     - returns:
     Descriptor of the survey config.
     */
    func getDescriptor() -> SyrveyDescriptor

    /**
     - returns:
     Version of the survey config.
     */
    func getVersion() -> String
}

/**
Abstracts a survey descriptor.
*/
public protocol SyrveyDescriptor {
    /**
     - returns:
     Array of forms.
     */
    func getForms() -> [SurveyForm]
}

/**
Abstracts a survey form.
*/
public protocol SurveyForm {
    /**
     - returns:
     Unique ID of the survey form.
     */
    func getID() -> Int
    
    /**
     - returns:
     Array of questions of the survey form.
     */
    func getQuestions() -> [SurveyQuestion]
 }

/**
Abstracts a survey question.
*/
public protocol SurveyQuestion {
    /**
     - returns:
     Type of the survey question.
     */
    func getType() -> SurveyType

    /**
     - returns:
     Text of the survey question.
     */
    func getText() -> String
    
    /**
     - returns:
     Array of options of the survey question.
     */
    func getOptions() -> [String]?
}

/**
 Supported survey question types.
 - seealso:
 `SurveyQuestion.getType()`
 */
public enum SurveyType {
    /**
     User need to rate something or somebody.
     */
    case stars
    
    /**
     User need to choose the option.
     */
    case radio
    
    /**
     User need to write comment.
     */
    case comment
}

/**
Abstracts a survey current question information.
*/
public protocol SurveyCurrentQuestionInfo {
    /**
     - returns:
     Unique ID of the form of the survey current question info.
     */
    func getFormID() -> Int
    
    /**
     - returns:
     Unique ID of the question of the survey current question info.
     */
    func getQuestionID() -> Int
}
