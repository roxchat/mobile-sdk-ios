
import Foundation

/**
 */

final class FileUrlCreator {
    
    // MARK: - Constants
    private enum Period: Int64 {
        case attachmentURLExpires = 300 // (seconds) = 5 (minutes).
    }

    // MARK: - Properties
    private weak var roxchatClient: RoxchatClient?
    private let serverURL: String
    
    // MARK: - Initialization
    init(roxchatClient: RoxchatClient,
         serverURL: String) {
        self.roxchatClient = roxchatClient
        self.serverURL = serverURL
    }
    
    // MARK: - Methods
    func createFileURL(byFilename filename: String, guid: String, isThumb: Bool = false) -> String? {
        guard let pageID = roxchatClient?.getDeltaRequestLoop().getAuthorizationData()?.getPageID(),
            let authorizationToken = roxchatClient?.getDeltaRequestLoop().getAuthorizationData()?.getAuthorizationToken() else {
                RoxchatInternalLogger.shared.log(entry: "Tried to access to message attachment without authorization data.")
                
                return nil
        }
        let expires = Int64(Date().timeIntervalSince1970) + Period.attachmentURLExpires.rawValue
        let data: String = guid + String(expires)
        if let hash = data.hmacSHA256(withKey: authorizationToken) {
            var formatedFilename = filename
            if let filenameWithAllowedCharacters = filename.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                formatedFilename = filenameWithAllowedCharacters
            } else {
                RoxchatInternalLogger.shared.log(entry: "Adding Percent Encoding With Allowed Characters failure in MessageImpl.\(#function)",
                                               verbosityLevel: .warning)
            }
            let baseURL = roxchatClient?.getDeltaRequestLoop().baseURL ?? serverURL
            let fileURLString = baseURL + ServerPathSuffix.downloadFile.rawValue + "/"
                + guid + "/"
                + formatedFilename + "?"
                + "page-id" + "=" + pageID + "&"
                + "expires" + "=" + String(expires) + "&"
                + "hash" + "=" + hash
                + (isThumb ? "&thumb=ios" : "")
            
            return fileURLString
        }
        RoxchatInternalLogger.shared.log(entry: "Error creating message attachment link due to HMAC SHA256 encoding error.")
        
        return nil
    }
}
