
import Foundation

/**
 Struct that encapsulates session authorization data.
 */
struct AuthorizationData {
    
    // MARK: - Properties
    private var pageID: String
    private var authorizationToken: String
    
    
    // MARK: - Initialization
    init?(pageID: String?,
          authorizationToken: String?) {
        guard let pageID = pageID,
            let authorizationToken = authorizationToken else {
            return nil
        }
        
        self.pageID = pageID
        self.authorizationToken = authorizationToken
    }
    
    
    // MARK: - Methods
    
    func getPageID() -> String {
        return pageID
    }
    
    func getAuthorizationToken() -> String? {
        return authorizationToken
    }
    
}

extension AuthorizationData: Equatable {
    
    static func == (lhs: AuthorizationData,
                    rhs: AuthorizationData) -> Bool {
        return (lhs.pageID == rhs.pageID)
            && (lhs.authorizationToken == rhs.authorizationToken)
    }
    
}
