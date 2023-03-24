
import Foundation

final class SendSurveyAnswerCompletionHandlerWrapper {
    private let sendSurveyAnswerCompletionHandler: SendSurveyAnswerCompletionHandler?
    private let surveyController: SurveyController
    
    init(surveyController: SurveyController,
         sendSurveyAnswerCompletionHandler: SendSurveyAnswerCompletionHandler? = nil) {
        self.surveyController = surveyController
        self.sendSurveyAnswerCompletionHandler = sendSurveyAnswerCompletionHandler
    }
    
    func onSuccess() {
        sendSurveyAnswerCompletionHandler?.onSuccess()
        surveyController.nextQuestion()
    }
    
    func onFailure(error: SendSurveyAnswerError) {
        sendSurveyAnswerCompletionHandler?.onFailure(error: error)
    }
}
