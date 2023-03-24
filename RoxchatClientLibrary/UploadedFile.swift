
import Foundation

/**
 Uploaded file.
 */
public protocol UploadedFile {
    var description: String { get }
    
    /**
     - returns:
     File size in bytes
     */
    func getSize() -> Int64

    /**
     * @return guid of a file
     */
    func getGuid() -> String
    
    /**
     - returns:
     File name.
     */
    func getFileName() -> String

    /**
     * @return MIME-type of a file
     */
    /**
     - returns:
     MIME-type of a file
     */
    func getContentType() -> String?

    /**
     * @return visitor Id of a file
     */
    /**
     - returns:
     Visitor ID.
     */
    func getVisitorID() -> String

    /**
     - returns:
     MIME-type of a file
     */
    func getClientContentType() -> String
    
    /**
     - seealso:
     `ImageInfo` protocol.
     - returns:
     If a file is an image, returns information about an image; in other cases returns nil.
     */
    func getImageInfo() -> ImageInfo?
}
