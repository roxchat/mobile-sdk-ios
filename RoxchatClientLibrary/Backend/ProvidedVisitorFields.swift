
import Foundation

/**
 Class that encapsulates unique visitor data.
 */
final class ProvidedVisitorFields {
    
    // MARK: - Properties
    private let id: String
    private let jsonString: String
    
    // MARK: - Initialization
    
    convenience init?(withJSONString jsonString: String) {
        if let jsonData = jsonString.data(using: .utf8) {
            self.init(jsonString: jsonString,
                      JSONObject: jsonData)
        } else {
            return nil
        }
    }
    
    convenience init?(withJSONObject jsonData: Data) {
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            RoxchatInternalLogger.shared.log(entry: "Getting String from json failure in ProvidedVisitorFields.\(#function)")
            return nil
        }
        
        self.init(jsonString: jsonString,
                  JSONObject: jsonData)
        
    }
    
    private init?(jsonString: String,
                  JSONObject: Data) {
        do {
            if let jsonData = try JSONSerialization.jsonObject(with: JSONObject) as? [String: Any] {
                if let fields = jsonData["fields"] as? [String: String] {
                    if let id = fields["id"] {
                        self.id = id
                    } else {
                        throw VisitorFieldsError.invalidVisitorFields("Visitor fields JSON object must contain ID field")
                    }
                } else if let id = jsonData["id"] as? String {
                    self.id = id
                } else {
                    throw VisitorFieldsError.invalidVisitorFields("Visitor fields JSON object must contain ID field")
                }
            } else {
                throw VisitorFieldsError.serializingFail("Error serializing visitor JSON data.")
            }
            
            self.jsonString = jsonString
        } catch {
            RoxchatInternalLogger.shared.log(entry: "Error serializing provided visitor fields: \(String(data: JSONObject, encoding: .utf8) ?? "unreadable data").",
                verbosityLevel: .debug)
            
            return nil
        }
    }
    
    // MARK: - Methods
    
    func getID() -> String {
        return id
    }
    
    func getJSONString() -> String {
        return jsonString
    }
    
    // MARK: -
    enum VisitorFieldsError: Error {
        case serializingFail(String)
        case invalidVisitorFields(String)
    }
    
}
