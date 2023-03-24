
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
    private var revision: Int64
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let revision = jsonDictionary[JSONField.revision.rawValue] as? Int64 {
            self.revision = revision
        } else {
            self.revision = 0
        }
    }
    
    // MARK: - Methods
    func getRevision() -> String {
        return String(revision)
    }
}
