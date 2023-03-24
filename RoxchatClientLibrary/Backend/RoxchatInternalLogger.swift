
import Foundation

/**
 Class that wraps `RoxchatLogger` into singleton pattern and encapsulates its verbose level.
 First, one should call `setup(roxchatLogger:verbosityLevel:)` method with particular parameters, then it will be possible to use `RoxchatInternalLogger.shared`.
 - seealso:
 `RoxchatLogger`.
 */
final class RoxchatInternalLogger {
    
    // MARK: - Properties
    static let shared = RoxchatInternalLogger()
    private static let setup = RoxchatInternalLoggerParametersHelper()
    
    // MARK: - Initialization
    private init() {
        // Needed for singleton pattern.
    }
    
    // MARK: - Methods
    
    class func setup(roxchatLogger: RoxchatLogger?,
                     verbosityLevel: SessionBuilder.RoxchatLoggerVerbosityLevel?,
                     availableLogTypes: [SessionBuilder.RoxchatLogType]) {
        RoxchatInternalLogger.setup.roxchatLogger = roxchatLogger
        RoxchatInternalLogger.setup.verbosityLevel = verbosityLevel
        RoxchatInternalLogger.setup.availableTypes = availableLogTypes
    }
    
    func log(entry: String,
             verbosityLevel: SessionBuilder.RoxchatLoggerVerbosityLevel = .error,
             logType: SessionBuilder.RoxchatLogType = .undefined) {
        guard canLog(type: logType) else { return }
        if !AbstractRequestLoop.logRequestData && logType == .networkRequest {
            return
        }
        let logEntry = "ROXCHAT LOG. \(currentDate()) \(entry)"
        switch verbosityLevel {
        case .verbose:
            if isVerbose() {
                RoxchatInternalLogger.setup.roxchatLogger?.log(entry: logEntry)
            }

            break
        case .debug:
            if isDebug() {
                RoxchatInternalLogger.setup.roxchatLogger?.log(entry: logEntry)
            }

            break
        case .info:
            if isInfo() {
                RoxchatInternalLogger.setup.roxchatLogger?.log(entry: logEntry)
            }

            break
        case .warning:
            if isWarning() {
                RoxchatInternalLogger.setup.roxchatLogger?.log(entry: logEntry)
            }

            break
        case .error:
            RoxchatInternalLogger.setup.roxchatLogger?.log(entry: logEntry)

            break
        }
    }
    
    // MARK: Private methods
    
    private func isVerbose() -> Bool {
        return (RoxchatInternalLogger.setup.verbosityLevel == .verbose)
    }
    
    private func isDebug() -> Bool {
        return ((RoxchatInternalLogger.setup.verbosityLevel == .debug)
            || (RoxchatInternalLogger.setup.verbosityLevel == .verbose))
    }
    
    private func isInfo() -> Bool {
        return ((RoxchatInternalLogger.setup.verbosityLevel == .verbose)
            || (RoxchatInternalLogger.setup.verbosityLevel == .debug)
            || (RoxchatInternalLogger.setup.verbosityLevel == .info))
    }
    
    private func isWarning() -> Bool {
        return ((RoxchatInternalLogger.setup.verbosityLevel == .verbose)
            || (RoxchatInternalLogger.setup.verbosityLevel == .debug)
            || (RoxchatInternalLogger.setup.verbosityLevel == .info)
            || (RoxchatInternalLogger.setup.verbosityLevel == .warning))
    }

    private func currentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: Date())
    }

    private func canLog(type: SessionBuilder.RoxchatLogType) -> Bool {
        return RoxchatInternalLogger.setup.availableTypes?.contains(type) == true
    }
    
}

/**
 Helper class for `RoxchatInternalLogger` singleton instance setup.
 - seealso:
 `RoxchatInternalLogger`.
 */
final class RoxchatInternalLoggerParametersHelper {
    
    // MARK: - Properties
    var verbosityLevel: SessionBuilder.RoxchatLoggerVerbosityLevel?
    var availableTypes: [SessionBuilder.RoxchatLogType]?
    weak var roxchatLogger: RoxchatLogger?
    
}
