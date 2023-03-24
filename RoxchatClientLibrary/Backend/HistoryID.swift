
import Foundation

/**
 Class that encapsulates message ID in history context.
 */
final class HistoryID {

    // MARK: - Properties
    private let dbID: String
    private let timeInMicrosecond: Int64
    
    // MARK: - Initialization
    init(dbID: String,
         timeInMicrosecond: Int64) {
        self.dbID = dbID
        self.timeInMicrosecond = timeInMicrosecond
    }
    
    // MARK: - Methods
    
    func getDBid() -> String {
        return dbID
    }
    
    func getTimeInMicrosecond() -> Int64 {
        return timeInMicrosecond
    }
    
}

extension HistoryID: Equatable {
    
    // MARK: - Methods
    static func == (lhs: HistoryID,
                    rhs: HistoryID) -> Bool {
        return ((lhs.dbID == rhs.dbID)
            && (lhs.timeInMicrosecond == rhs.timeInMicrosecond))
    }
    
}
