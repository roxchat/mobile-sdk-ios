
import Foundation

/**
 */
class FAQActions {
    
    // MARK: - Constants
    enum Parameter: String {
        case application = "app"
        case categoryId = "categoryid"
        case departmentKey = "department-key"
        case itemId = "itemid"
        case language = "lang"
        case limit = "limit"
        case open = "open"
        case platform = "platform"
        case query = "query"
        case userId = "userid"
    }
    enum ServerPathSuffix: String {
        case item = "/services/faq/v1/item"
        case category = "/services/faq/v1/category"
        case categories = "/roxchat/api/v1/faq/category"
        case structure = "/services/faq/v1/structure"
        case search = "/services/faq/v1/search"
        case like = "/services/faq/v1/like"
        case dislike = "/services/faq/v1/dislike"
        case track = "/services/faq/v1/track"
    }
    
    // MARK: - Properties
    private let baseURL: String
    private let faqRequestLoop: FAQRequestLoop
    private static let deviceID = ClientSideID.generateClientSideID()
    
    // MARK: - Initialization
    init(baseURL: String,
         faqRequestLoop: FAQRequestLoop) {
        self.baseURL = baseURL
        self.faqRequestLoop = faqRequestLoop
    }
    
    // MARK: - Methods
    
    func getItem(itemId: String,
                 completion: @escaping (_ faqItem: Data?) throws -> ()) {
        let dataToPost = [Parameter.itemId.rawValue: itemId,
                          Parameter.userId.rawValue: FAQActions.deviceID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.item.rawValue
        
        faqRequestLoop.enqueue(request: RoxchatRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func getCategory(categoryId: String,
                     completion: @escaping (_ faqCategory: Data?) throws -> ()) {
        let dataToPost = [Parameter.categoryId.rawValue: categoryId,
                          Parameter.userId.rawValue: FAQActions.deviceID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.category.rawValue
        
        faqRequestLoop.enqueue(request: RoxchatRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func getCategoriesFor(application: String,
                          language: String,
                          departmentKey: String,
                          completion: @escaping (_ faqCategories: Data?) throws -> ()) {
        let dataToPost = [Parameter.application.rawValue: application,
                          Parameter.platform.rawValue: "ios",
                          Parameter.language.rawValue: language,
                          Parameter.departmentKey.rawValue: departmentKey] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.categories.rawValue
        
        faqRequestLoop.enqueue(request: RoxchatRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func getStructure(categoryId: String,
                      completion: @escaping (_ faqStructure: Data?) throws -> ()) {
        let dataToPost = [Parameter.categoryId.rawValue: categoryId] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.structure.rawValue
        
        faqRequestLoop.enqueue(request: RoxchatRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func search(query: String,
                categoryId: String,
                limit: Int,
                completion: @escaping (_ data: Data?) throws -> ()) {
        let dataToPost = [Parameter.categoryId.rawValue: categoryId,
                          Parameter.query.rawValue: query,
                          Parameter.limit.rawValue: limit] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.search.rawValue
        
        faqRequestLoop.enqueue(request: RoxchatRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func like(itemId: String,
              completion: @escaping (_ data: Data?) throws -> ()) {
        let dataToPost = [Parameter.itemId.rawValue: itemId,
                          Parameter.userId.rawValue: FAQActions.deviceID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.like.rawValue
        
        faqRequestLoop.enqueue(request: RoxchatRequest(httpMethod: .post,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func dislike(itemId: String,
                 completion: @escaping (_ data: Data?) throws -> ()) {
        let dataToPost = [Parameter.itemId.rawValue: itemId,
                          Parameter.userId.rawValue: FAQActions.deviceID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.dislike.rawValue
        
        faqRequestLoop.enqueue(request: RoxchatRequest(httpMethod: .post,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func track(itemId: String,
               openFrom: FAQItemSource) {
        let source: String
        switch openFrom {
            case .search:
                source = "search"
            case .tree:
                source = "tree"
        }
        let dataToPost = [Parameter.itemId.rawValue: itemId,
                          Parameter.open.rawValue: source] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.track.rawValue
        
        faqRequestLoop.enqueue(request: RoxchatRequest(httpMethod: .post,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString))
    }
}
