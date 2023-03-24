
import Foundation

/**
 */
final class FAQClientBuilder {
    
    // MARK: - Properties
    private var application: String?
    private var baseURL: String?
    private var departmentKey: String?
    private var language: String?
    private var completionHandlerExecutor: ExecIfNotDestroyedFAQHandlerExecutor?
    
    // MARK: - Builder methods
    
    func set(baseURL: String) -> FAQClientBuilder {
        self.baseURL = baseURL
        
        return self
    }
    
    func set(application: String?) -> FAQClientBuilder {
        self.application = application
        
        return self
    }
    
    func set(departmentKey: String?) -> FAQClientBuilder {
        self.departmentKey = departmentKey
        
        return self
    }
    
    func set(language: String?) -> FAQClientBuilder {
        self.language = language
        
        return self
    }
    
    func set(completionHandlerExecutor: ExecIfNotDestroyedFAQHandlerExecutor?) -> FAQClientBuilder {
        self.completionHandlerExecutor = completionHandlerExecutor
        
        return self
    }
    
    func build() -> FAQClient {
        guard let handler = completionHandlerExecutor else {
            RoxchatInternalLogger.shared.log(entry: "Completion Handler Executor is nil in FAQClient.\(#function)")
            fatalError("Completion Handler Executor is nil in FAQClient.\(#function)")
        }
        let faqRequestLoop = FAQRequestLoop(completionHandlerExecutor: handler)
        
        guard let baseURL = baseURL else {
            RoxchatInternalLogger.shared.log(entry: "Base URL is nil in FAQClient.\(#function)")
            fatalError("Base URL is nil in FAQClient.\(#function)")
        }
        
        return FAQClient(withFAQRequestLoop: faqRequestLoop,
                         faqActions: FAQActions(baseURL: baseURL,
                                                faqRequestLoop: faqRequestLoop),
                         application: application,
                         departmentKey: departmentKey,
                         language: language)
    }
    
}

/**
 */
final class FAQClient {
    
    // MARK: - Properties
    private let faqRequestLoop: FAQRequestLoop
    private let faqActions: FAQActions
    private let application: String?
    private let departmentKey: String?
    private let language: String?
    
    // MARK: - Initialization
    init(withFAQRequestLoop faqRequestLoop: FAQRequestLoop,
         faqActions: FAQActions,
         application: String?,
         departmentKey: String?,
         language: String?) {
        self.faqRequestLoop = faqRequestLoop
        self.faqActions = faqActions
        self.application = application
        self.departmentKey = departmentKey
        self.language = language
    }
    
    // MARK: - Methods
    
    func start() {
        faqRequestLoop.start()
    }
    
    func pause() {
        faqRequestLoop.pause()
    }
    
    func resume() {
        faqRequestLoop.resume()
    }
    
    func stop() {
        faqRequestLoop.stop()
    }
    
    func getActions() -> FAQActions {
        return faqActions
    }
    
    func getApplication() -> String? {
        return application
    }
    
    func getDepartmentKey() -> String? {
        return departmentKey
    }
    
    func getLanguage() -> String? {
        return language
    }
}
