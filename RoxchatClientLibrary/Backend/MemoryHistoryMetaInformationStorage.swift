
import Foundation

/**
 */
final class MemoryHistoryMetaInformationStorage: HistoryMetaInformationStorage {
    
    // MARK: - Properties
    private var historyEnded = false
    
    // MARK: - Methods
    // MARK: HistoryMetaInformationStorage protocol methods
    
    func isHistoryEnded() -> Bool {
        return historyEnded
    }
    
    func set(historyEnded: Bool) {
        self.historyEnded = historyEnded
    }
    
    func set(revision: String?) {
        // No need to do anything in this implementation.
    }
    
    func getRevision() -> String? {
        // No need to do anything in this implementation.
        return nil
    }
    
}
