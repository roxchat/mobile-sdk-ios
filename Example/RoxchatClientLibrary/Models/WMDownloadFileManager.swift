
import UIKit
import Nuke
import RoxchatClientLibrary

protocol WMDownloadFileManagerDelegate: AnyObject {
    func updateImageDownloadProgress(url: URL, progress: Float, image: UIImage? )
}

class WMDownloadFileManager {
    
    private var fileGuidURLDictionary: [String: String] = (WMKeychainWrapper.standard.dictionary(forKey: WMKeychainWrapper.fileGuidURLDictionaryKey) as? [String: String]) ?? [:]
    
    private var delegatesSet = Set<WMWeakReferenseContainer<WMDownloadFileManagerDelegate>>()
    
    func addDelegate(delegate: WMDownloadFileManagerDelegate) {
        delegatesSet.insert(WMWeakReferenseContainer(delegate))
    }
    
    func removeDelegate(delegate: AnyObject) {
        delegatesSet = delegatesSet.filter { $0.getValue() != nil && $0.getValue() as AnyObject !== delegate }
    }
    
    static var shared = WMDownloadFileManager()
    
    func saveUrl(_ url: URL?, forGuid guid: String) {
        self.fileGuidURLDictionary[guid] = url?.absoluteString
        WMKeychainWrapper.standard.setDictionary(fileGuidURLDictionary, forKey: WMKeychainWrapper.fileGuidURLDictionaryKey)
    }
    
    var progressDictionary: [URL: Float] = [:]
    
    func progressForURL(_ url: URL?) -> Float {
        if let url = url {
            return progressDictionary[url] ?? 0
        }
        return 0
    }
    
    private func  expiredFromUrl(_ url: URL?) -> Int64 {
        return Int64(url?.queryParameters?["expires"] ?? "0") ?? 0
    }
    
    func imageForFileInfo(_ fileInfo: FileInfo?) -> UIImage? {
        return nil
    }
    
    func urlFromFileInfo(_ fileInfo: FileInfo?) -> URL? {
        guard let fileInfo = fileInfo else { return nil }
        
        if let guid = fileInfo.getGuid() {
            
            if let cachedUrlString = self.fileGuidURLDictionary[guid] {  // check url cached and not expired
                let url = URL(string: cachedUrlString)
                let expires = self.expiredFromUrl(url)
                if Int64(Date().timeIntervalSince1970) < expires {
                    return url
                } else {
                    self.saveUrl(fileInfo.getURL(), forGuid: guid)
                }
            } else {
                self.saveUrl(fileInfo.getURL(), forGuid: guid)
            }
            
            return URL(string: self.fileGuidURLDictionary[guid] ?? "")
        }
        return fileInfo.getURL()
    }
    
    func imageForUrl(_ url: URL) -> UIImage? {

        let request = ImageRequest(url: url)
        if let image = ImageCache.shared[request] {
            return image

        } else {

            Nuke.ImagePipeline.shared.loadImage(
                with: url,
                progress: { _, completed, total in
                    
                    self.delegatesSet = self.delegatesSet.filter { $0.getValue() != nil }
                    
                    self.delegatesSet.forEach { container in
                        container.getValue()?.updateImageDownloadProgress(
                            url: url,
                            progress: Float(total) == 0 ? 0 : Float(completed) / Float(total),
                            image: nil
                        )
                    }
                },
                completion: { _ in
                    self.delegatesSet = self.delegatesSet.filter { $0.getValue() != nil }
                    self.delegatesSet.forEach { container in
                        container.getValue()?.updateImageDownloadProgress(
                            url: url,
                            progress: 1,
                            image: ImageCache.shared[request]
                        )
                    }
                }
            )
        }

        return nil
    }
}
