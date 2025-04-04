
import Foundation

/**
 Class that encapsulates chat update respnonce, requested from a server.
 */
final class DeltaResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case deltaList = "deltaList"
        case fullUpdate = "fullUpdate"
        case revision = "revision"
    }
    
    // MARK: - Properties
    private lazy var deltaList = [DeltaItem]()
    private var fullUpdate: FullUpdate?
    private var revision: String?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        let revision = jsonDictionary[JSONField.revision.rawValue]
        if let revision = revision as? String {
            self.revision = revision
        } else if let revision = revision as? Int {
            self.revision = String(revision)
        }
        
        if let fullUpdateValue = jsonDictionary[JSONField.fullUpdate.rawValue] as? [String: Any?] {
            fullUpdate = FullUpdate(jsonDictionary: fullUpdateValue)
        }
        
        if let deltaItemArray = jsonDictionary[JSONField.deltaList.rawValue] as? [Any] {
            for arrayItem in deltaItemArray {
                if let arrayItem = arrayItem as? [String: Any?] {
                    if let deltaItem = DeltaItem(jsonDictionary: arrayItem) {
                        deltaList.append(deltaItem)
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    func getRevision() -> String? {
        return revision
    }
    
    func getFullUpdate() -> FullUpdate? {
        return fullUpdate
    }
    
    func getDeltaList() -> [DeltaItem]? {
        return deltaList
    }
    
}
