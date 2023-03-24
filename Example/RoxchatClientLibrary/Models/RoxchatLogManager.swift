
import Foundation
import RoxchatClientLibrary

protocol RoxchatLogManagerSubject {
    func add(observer: RoxchatLogManagerObserver)
    func remove(observer: RoxchatLogManagerObserver)
    func notify(with log: String)
}

class RoxchatLogManager: RoxchatLogManagerSubject {

    static let shared = RoxchatLogManager()

    var observerCollection = NSMutableSet()

    private var logs: [String]

    init() {
        logs = []
    }

    func getLogs() -> [String] {
        return logs
    }

    func add(observer: RoxchatLogManagerObserver) {
        observerCollection.add(observer)
    }

    func remove(observer: RoxchatLogManagerObserver) {
        observerCollection.remove(observer)
    }

    func notify(with log: String) {
        observerCollection.forEach { observer in
            guard let observer = observer as? RoxchatLogManagerObserver else { return }
            observer.didGetNewLog(log: log)
        }
    }
}

extension RoxchatLogManager: RoxchatLogger {
    func log(entry: String) {
        print(entry)
        logs.append(entry)
        notify(with: entry)
    }
}
