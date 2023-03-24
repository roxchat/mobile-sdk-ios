
import Foundation

/**
 */
class RemoteHistoryProvider {
    
    // MARK: - Properties
    private var roxchatActions: RoxchatActionsImpl
    private var historyMessageMapper: MessageMapper
    private var historyMetaInformationStorage: HistoryMetaInformationStorage
    
    // MARK: - Initialization
    init(roxchatActions: RoxchatActionsImpl,
         historyMessageMapper: MessageMapper,
         historyMetaInformationStorage: HistoryMetaInformationStorage) {
        self.roxchatActions = roxchatActions
        self.historyMessageMapper = historyMessageMapper
        self.historyMetaInformationStorage = historyMetaInformationStorage
    }
    
    // MARK: - Methods
    func requestHistory(beforeTimestamp: Int64,
                        completion: @escaping ([MessageImpl], Bool) -> ()) {
        roxchatActions.requestHistory(beforeMessageTimestamp: beforeTimestamp) { [weak self] data in
            guard let `self` = self,
                let data = data else {
                completion([MessageImpl](), false)
                
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data,
                                                         options: [])
            if let historyBeforeResponseDictionary = json as? [String: Any?] {
                let historyBeforeResponse = HistoryBeforeResponse(jsonDictionary: historyBeforeResponseDictionary)
                
                if let messages = historyBeforeResponse.getData()?.getMessages() {
                    completion(self.historyMessageMapper.mapAll(messages: messages), (historyBeforeResponse.getData()?.isHasMore() == true))
                    
                    if historyBeforeResponse.getData()?.isHasMore() != true {
                        self.historyMetaInformationStorage.set(historyEnded: true)
                    }
                } else {
                    completion([MessageImpl](), false)
                    self.historyMetaInformationStorage.set(historyEnded: true)
                }
            }
        }
    }
    
}
