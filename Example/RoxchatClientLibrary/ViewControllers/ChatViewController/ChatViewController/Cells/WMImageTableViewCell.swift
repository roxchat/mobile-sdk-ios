
import UIKit
import RoxchatClientLibrary

class WMImageTableViewCell: WMMessageTableCell, WMFileDownloadProgressListener {
    
    @IBOutlet var imageAspectConstraint: NSLayoutConstraint!
    @IBOutlet var imagePreview: UIImageView!
    @IBOutlet var downloadProcessIndicator: CircleProgressIndicator!
    
    var currentAspectRaito: CGFloat = -1
    var url: URL?
    
    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
        
        self.imagePreview.image = UIImage(named: "placeholder")
        if let attachment = message.getData()?.getAttachment(), let imageURL = WMDownloadFileManager.shared.urlFromFileInfo(attachment.getFileInfo()) {
            self.url = imageURL
            WMFileDownloadManager.shared.subscribeForImage(url: imageURL, progressListener: self)
        }
    }
    
    func updateAspectConstraint( aspectRatio: CGFloat) {
        if self.currentAspectRaito != aspectRatio {
            self.currentAspectRaito = aspectRatio
            self.imageAspectConstraint.isActive = false
            self.imagePreview.removeConstraint(self.imageAspectConstraint)
            
            if let imageView = self.imagePreview {
                self.imageAspectConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: aspectRatio, constant: 0)
            }
            self.imagePreview.addConstraint(self.imageAspectConstraint)
            self.imageAspectConstraint.isActive = true
            self.tableView?.reloadData()
        }
    }
    
    func progressChanged(url: URL, progress: Float, image: UIImage?) {
        if url != self.url {
            return
        }
        if let image = image {
            let aspectRatio = image.size.height / image.size.width
            
            self.imagePreview.image = image
            self.downloadProcessIndicator.isHidden = true
            self.updateAspectConstraint(aspectRatio: aspectRatio)
        } else {
            if progress == 1.0 {
                self.downloadProcessIndicator.isHidden = true
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    if self.tableView?.visibleCells.contains(self) ?? false {
                        WMFileDownloadManager.shared.subscribeForImage(url: self.url!, progressListener: self)
                    }
                }
            } else {
                if progress != 0.0 {
                    self.downloadProcessIndicator.isHidden = false
                    self.downloadProcessIndicator.updateImageDownloadProgress(progress)
                }
                self.updateAspectConstraint(aspectRatio: 1.0)
            }
        }
    }
    
    @objc func imageViewTapped() {
        self.delegate?.imageViewTapped(message: self.message, image: self.imagePreview.image, url: self.url)
    }
    
    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            let imageTapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(imageViewTapped)
            )
            self.imagePreview?.gestureRecognizers = nil
            self.imagePreview?.addGestureRecognizer(imageTapGestureRecognizer)
        }
        return setup
    }
    
}
