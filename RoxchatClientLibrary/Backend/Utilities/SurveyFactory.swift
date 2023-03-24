
import Foundation

/**
 Mapper class that is responsible for converting internal survey model objects to public ones.
 */
final class SurveyFactory {
    
    // MARK: - Methods
    func createSurveyFrom(surveyItem: SurveyItem) -> Survey? {
        guard let configItem = surveyItem.getConfig(),
              let config = createConfigFrom(configItem: configItem),
              let currentQuestionInfoItem = surveyItem.getCurrentQuestionInfo(),
              let currentQuestionInfo = createCurrentQuestionInfoFrom(currentQuestionInfoItem: currentQuestionInfoItem),
              let id = surveyItem.getID() else {
            return nil
        }
        return SurveyImpl(config: config,
                          currentQuestionInfo: currentQuestionInfo,
                          id: id)
    }

    private func createConfigFrom(configItem: ConfigItem) -> SurveyConfig? {
        guard let descriptorItem = configItem.getDescriptor(),
            let descriptor = createDescriptorFrom(descriptorItem: descriptorItem),
            let id = configItem.getID(),
            let version = configItem.getVersion() else {
                return nil
        }
        return ConfigImpl(id: id,
                          descriptor: descriptor,
                          version: version)
    }

    private func createDescriptorFrom(descriptorItem: DescriptorItem) -> SyrveyDescriptor? {
        var forms = [SurveyForm]()
        guard let formItems = descriptorItem.getForms() else {
            return nil
        }
        for form in formItems {
            if let formID = form.getID(),
                let questionItems = form.getQuestions() {
                let formImpl = FormImpl(id: formID, questions: createQuestionsFrom(questionItems: questionItems))
                forms.append(formImpl)
            }
        }
        return DescriptorImpl(forms: forms)
    }

    private func createQuestionsFrom(questionItems: [QuestionItem]) -> [SurveyQuestion] {
        var questions = [SurveyQuestion]()
        for questionItem in questionItems {
            if let text = questionItem.getText() {
                let questionImpl = QuestionImpl(type: toQuestionType(questionKind: questionItem.getType()),
                                                text: text,
                                                options: questionItem.getOptions())
                questions.append(questionImpl)
            }
        }
        return questions
    }
    
    private func toQuestionType(questionKind: QuestionItem.QuestionKind?) -> SurveyType {
        switch questionKind {
        case .stars:
            return .stars
        case .radio:
            return .radio
        case .comment,
             .none:
            return .comment
        }
    }
    
    private func createCurrentQuestionInfoFrom(currentQuestionInfoItem: CurrentQuestionInfoItem) -> SurveyCurrentQuestionInfo? {
        guard let formID = currentQuestionInfoItem.getFormID(),
              let questionID = currentQuestionInfoItem.getQuestionID() else {
            return nil
        }
        return CurrentQuestionInfoImpl(formID: formID,
                                       questionID: questionID)
    }
    
}
