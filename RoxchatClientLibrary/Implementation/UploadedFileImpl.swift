
import Foundation

/**
 Internal uploaded file representasion.
 */
class UploadedFileImpl {
    
    // MARK: - Properties
    private let size: Int64
    private let guid: String
    private let contentType: String?
    private let filename: String
    private let visitorID: String
    private let clientContentType: String
    private let imageParameters: ImageParameters?
    
    // MARK: - Initialization
    init(size: Int64,
         guid: String,
         contentType: String?,
         filename: String,
         visitorID: String,
         clientContentType: String,
         imageParameters: ImageParameters?) {
        self.size = size
        self.guid = guid
        self.contentType = contentType
        self.filename = filename
        self.visitorID = visitorID
        self.clientContentType = clientContentType
        self.imageParameters = imageParameters
    }
}

extension UploadedFileImpl: UploadedFile {
    public var description: String {
        let imageSize = imageParameters?.getSize()
        return "{\"client_content_type\":\"\(clientContentType)\"" +
            ",\"visitor_id\":\"\(visitorID)\"" +
            ",\"filename\":\"\(filename)\"" +
            ",\"content_type\":\"\(contentType ?? "")\"" +
            ",\"guid\":\"\(guid)\"" +
            (imageSize != nil ? ",\"image\":{\"size\":{\"width\":\( imageSize?.getWidth() ?? 0),\"height\":\(imageSize?.getHeight() ?? 0)}}" : "") +
            ",\"size\":\(size)}"
    }
    
    func getSize() -> Int64 {
        return size
    }
    
    func getGuid() -> String {
        return guid
    }
    
    func getFileName() -> String {
        return filename
    }
    
    func getContentType() -> String? {
        return contentType
    }
    
    func getVisitorID() -> String {
        return visitorID
    }
    
    func getClientContentType() -> String {
        return clientContentType
    }
    
    func getImageInfo() -> ImageInfo? {
        return ImageInfoImpl(withThumbURLString: "",
                             fileUrlCreator: nil,
                             filename: filename,
                             guid: guid,
                             width: imageParameters?.getSize()?.getWidth(),
                             height: imageParameters?.getSize()?.getHeight())
    }
}
