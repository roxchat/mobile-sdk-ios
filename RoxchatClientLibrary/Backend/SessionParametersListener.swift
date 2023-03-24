
import Foundation

/**
 Class that is responsible for history storage when it is set to memory mode.
 */
protocol SessionParametersListener {
    
    func onSessionParametersChanged(visitorFieldsJSONString: String,
                                    sessionID: String,
                                    authorizationData: AuthorizationData)
    
}
