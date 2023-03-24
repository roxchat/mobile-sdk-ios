
import Foundation

/**
 Class which is responsible for generating random IDs (e.g. for sending messages).
 */
struct ClientSideID {
    
    // MARK: - Constants
    enum StringSize: Int {
        case clientSideID = 32
    }
    enum StringSymbols: NSString {
        case uid = "abcdef0123456789"
    }
    
    // MARK: - Methods
    
    static func generateClientSideID() -> String {
        return generateRandomString(ofCharactersNumber: StringSize.clientSideID.rawValue)
    }
    
    static func generateRandomString(ofCharactersNumber numberOfCharacters: Int) -> String {
        let letters: NSString = StringSymbols.uid.rawValue
        let length = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< numberOfCharacters {
            let random = arc4random_uniform(length)
            var nextChar = letters.character(at: Int(random))
            randomString = randomString + (NSString(characters: &nextChar,
                                                    length: 1) as String)
        }
        
        return randomString
    }
    
}
