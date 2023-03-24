
import Foundation

/**
 */
protocol HistoryMetaInformationStorage {
    
    func isHistoryEnded() -> Bool
    
    func set(historyEnded: Bool)
    
    func set(revision: String?)
    
    func getRevision() -> String?
    
}
