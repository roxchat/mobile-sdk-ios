
import Foundation

/**
 */
final class HistoryRevisionItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case revision = "revision"
    }
    
    // MARK: - Properties
    private var revision: String
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        let revision = jsonDictionary[JSONField.revision.rawValue]
        if let revision = revision as? String {
            self.revision = revision
        } else if let revision = revision as? Int {
            self.revision = String(revision)
        } else {
            self.revision = "0"
        }
    }
    
    // MARK: - Methods
    func getRevision() -> String {
        return String(revision)
    }
}
