
import UIKit
import Nuke

protocol WMFileDownloadProgressListener: AnyObject {
    func progressChanged(url: URL, progress: Float, image: UIImage?)
}

typealias DownloadListenerContainer = WMWeakReferenseContainer<WMFileDownloadProgressListener>

class WMFileDownloadManager: NSObject {
    
    public static var shared = WMFileDownloadManager()
    private var progressDictionary = [URL: Float]()
    private var listeners = [URL: Set<DownloadListenerContainer>]()
    
    static func dropListeners() {
        AppDelegate.checkMainThread()
        shared.listeners = [URL: Set<DownloadListenerContainer>]()
    }
    
    func addProgressListener(url: URL, listener: WMFileDownloadProgressListener) {
        AppDelegate.checkMainThread()
        if !listeners.containsKey(keySearch: url) {
            listeners[url] = Set<DownloadListenerContainer>()
        }
        listeners[url]?.insert(WMWeakReferenseContainer(listener))
    }
    
    func removeListener(listener: WMFileDownloadProgressListener, url: URL) {
        AppDelegate.checkMainThread()
        listeners[url] = listeners[url]?.filter { $0.getValue() != nil && $0.getValue() !== listener }
    }
    
    func sendProgressChangedEventFor(url: URL, progress: Float, image: UIImage?) {
        for listenerContainer in listeners[url] ?? [] {
            listenerContainer.getValue()?.progressChanged(url: url, progress: progress, image: image)
        }
        if image != nil {
            // remove all listeners when image is downloaded
            listeners[url] = nil
        } else {
            // filter released listeners
            listeners[url] = listeners[url]?.filter { $0.getValue() != nil }
        }
    }
    
    func subscribeForImage(url: URL, progressListener: WMFileDownloadProgressListener) {
        AppDelegate.checkMainThread()
        let request = ImageRequest(url: url)
        if let imageContainer = ImageCache.shared[request] {
            progressListener.progressChanged(url: url, progress: 1, image: imageContainer)
        } else {
            self.addProgressListener(url: url, listener: progressListener)

            progressListener.progressChanged(url: url, progress: progressDictionary[url] ?? 0, image: nil)

            Nuke.ImagePipeline.shared.loadImage(
                with: url,
                progress: { _, completed, total in
                    var progress = Float(1.0)
                    if total != 0 {
                        progress = Float(completed) / Float(total)
                    }
                    AppDelegate.checkMainThread()
                    self.progressDictionary[url] = progress
                    self.sendProgressChangedEventFor(url: url, progress: progress, image: nil)
                },
                completion: { _ in
                    AppDelegate.checkMainThread()
                    self.sendProgressChangedEventFor(url: url, progress: 1, image: ImageCache.shared[request])
                }
            )
        }
    }
}
