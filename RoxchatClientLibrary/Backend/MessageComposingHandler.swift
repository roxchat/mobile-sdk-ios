
import Foundation

/**
 Class that is responsible for sending drafts of visitor typed messages to an operator side chat.
 */
final class MessageComposingHandler {
    
    // MARK: - Constants
    private enum Deadline: Int {
        case draftSendingInterval = 1 // Second
        case resetStatusDelay = 5 // Second
    }
    
    // MARK: - Properties
    private let queue: DispatchQueue
    private let roxchatActions: RoxchatActions
    private var latestDraft: String?
    private var resetTimer: Timer?
    private var updateDraftScheduled = false
    
    // MARK: - Initialization
    init(roxchatActions: RoxchatActions,
         queue: DispatchQueue) {
        self.roxchatActions = roxchatActions
        self.queue = queue
    }
    
    // MARK: - Methods
    
    func setComposing(draft: String?) {
        latestDraft = draft
        
        if !updateDraftScheduled {
            send(draft: draft)
            updateDraftScheduled = true
            
            queue.asyncAfter(deadline: (DispatchTime.now() + .seconds(Deadline.draftSendingInterval.rawValue)),
                             execute: { [weak self] in
                                guard let `self` = self else {
                                    return
                                }
                                
                                self.updateDraftScheduled = false
                                
                                if self.latestDraft != draft {
                                    self.send(draft: self.latestDraft)
                                }
            })
        }
        
        resetTimer?.invalidate()
        
        if draft != nil {
            let resetTime = Date().addingTimeInterval(Double(Deadline.resetStatusDelay.rawValue))
            resetTimer = Timer(fireAt: resetTime,
                               interval: 0.0,
                               target: self,
                               selector: #selector(resetTypingStatus),
                               userInfo: nil,
                               repeats: false)
            
            guard let resetTimer = resetTimer else {
                RoxchatInternalLogger.shared.log(entry: "Reset Timer is nil in MessageComposingHandler.\(#function)")
                return
            }
            RunLoop.main.add(resetTimer,
                             forMode: RunLoop.Mode.common)
        }
    }
    
    // MARK: Private methods
    
    @objc
    private func resetTypingStatus() {
        queue.async {
            self.roxchatActions.set(visitorTyping: false,
                                  draft: nil,
                                  deleteDraft: false)
        }
    }
    
    private func send(draft: String?) {
        if let draft = draft {
            roxchatActions.set(visitorTyping: draft.isEmpty ? false : true,
                             draft: draft,
                             deleteDraft: draft.isEmpty ? true : false)
        } else {
            roxchatActions.set(visitorTyping: false,
                             draft: draft,
                             deleteDraft: true)
        }
    }
    
}
