
import Foundation

/**
 */

final class SurveyController {
    
    // MARK: - Properties
    private weak var surveyListener: SurveyListener?
    private var survey: Survey?
    private var currentFormPointer = 0
    private var currentQuestionPointer = 0

     // MARK: - Initialization
    init(surveyListener: SurveyListener) {
        self.surveyListener = surveyListener
    }

     // MARK: - Methods
    func set(survey: Survey) {
        self.survey = survey
        setCurrentQuestionPointer()
        surveyListener?.on(survey: survey)
    }

    func getSurvey() -> Survey? {
        return survey
    }

    func getCurrentFormID() -> Int {
        let forms = survey?.getConfig().getDescriptor().getForms()
        return forms?[currentFormPointer].getID() ?? 0
    }

    func getCurrentQuestionPointer() -> Int {
        return currentQuestionPointer
    }

    func nextQuestion() {
        if let question = getCurrentQuestion() {
            surveyListener?.on(nextQuestion: question)
        }
    }

    func cancelSurvey() {
        surveyListener?.onSurveyCancelled()
        survey = nil
        currentFormPointer = 0
        currentQuestionPointer = 0
    }

    private func getCurrentQuestion() -> SurveyQuestion? {
        guard let survey = survey else {
            return nil
        }
        let forms = survey.getConfig().getDescriptor().getForms()
        guard forms.count > currentFormPointer else {
            return nil
        }
        let form = forms[currentFormPointer]

        let questions = form.getQuestions()
        currentQuestionPointer += 1
        if questions.count <= currentQuestionPointer {
            currentQuestionPointer = -1
            currentFormPointer += 1
            return getCurrentQuestion()
        }
        return questions[currentQuestionPointer]
    }

    private func setCurrentQuestionPointer() {
        guard let survey = survey else {
            return
        }
        let forms = survey.getConfig().getDescriptor().getForms()
        let questionInfo = survey.getCurrentQuestionInfo()
        currentQuestionPointer = questionInfo.getQuestionID() - 1

        for (i, form) in forms.enumerated() {
            if form.getID() == questionInfo.getFormID() {
                currentFormPointer = i
                break
            }
        }
    }
}
