
import UIKit
import RoxchatClientLibrary

class FileMessage: WMMessageTableCell, WMDocumentDownloadTaskDelegate {
    @IBOutlet var fileName: UILabel!
    @IBOutlet var fileDescription: UILabel?
    @IBOutlet var downloadStatusLabel: UILabel?
    @IBOutlet var fileStatus: UIButton!
    @IBOutlet var fileDownloadIndicator: CircleProgressIndicator?
    
    var isForOperator = false
    
    var documentDownloadTask: WMDocumentDownloadTask?
    
    static let byteCountFormatter: ByteCountFormatter = {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = .useAll
        byteCountFormatter.countStyle = .file
        byteCountFormatter.includesUnit = true
        byteCountFormatter.isAdaptive = true
        return byteCountFormatter
    }()
    
    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
        let fileSize = message.getData()?.getAttachment()?.getFileInfo().getSize() ?? -1
        let sendStatus = message.getSendStatus() == .sent
        if sendStatus {
            if let attachment = message.getData()?.getAttachment(),
               let fileURL = WMDownloadFileManager.shared.urlFromFileInfo(attachment.getFileInfo()) {
                self.documentDownloadTask = WMDocumentDownloadTask.documentDownloadTaskFor(url: fileURL, fileSize: fileSize, delegate: self)
            }
            self.isForOperator = false
            self.fileName?.text = message.getData()?.getAttachment()?.getFileInfo().getFileName()
            resetFileStatus()
        } else {
            self.fileName?.text = "Uploading file".localized
            self.fileStatus.setBackgroundImage(UIImage(named: "FileUploadButtonVisitor")!.colour(documentIcomColor), for: .normal)
            self.fileDescription?.text = "File is being sent".localized
        }
        self.fileDownloadIndicator?.isHidden = true
        self.downloadStatusLabel?.text = ""
    }
    
    @IBAction func openFile(_ sender: Any) {
        if documentDownloadTask?.isDownloaded ?? false {
            self.fileStatus.setBackgroundImage( UIImage(named: "FileDownloadSuccess")!, for: .normal )
            delegate?.openFile(message: self.message, url: documentDownloadTask?.localFileUrl)
        } else {
            self.documentDownloadTask?.downloadFile()
        }
    }
    
    func fileDownloadFaild(downloadFileUrl: URL) {
        if documentDownloadTask?.fileURL != downloadFileUrl {
            return
        }
        print("fileDownloadFaild \(downloadFileUrl)")
        resetFileStatus()
    }
    
    func updateFileDownloadProgress(downloadFileUrl: URL, progress: Float, localFileUrl: URL?) {
        if documentDownloadTask?.fileURL != downloadFileUrl {
            print("wrong cell progress ")
            return
        }
        if localFileUrl != nil {
            self.fileDownloadIndicator?.isHidden = true
            self.fileStatus.isHidden = false
            self.fileStatus.setBackgroundImage( UIImage(named: "FileDownloadSuccess")!, for: .normal)
            self.downloadStatusLabel?.text = ""
            delegate?.openFile(message: self.message, url: localFileUrl)
        } else {
            self.fileStatus.isHidden = true
            self.downloadStatusLabel?.text = ""

            if self.fileDownloadIndicator?.isHidden ?? false {
                self.fileDownloadIndicator?.isHidden = false
                self.fileDownloadIndicator?.enableRotationAnimation()
                self.fileStatus.isHidden = true
            }
            self.fileDownloadIndicator?.setProgressWithAnimation(
                duration: 0.1,
                value: progress
            )
            self.downloadStatusLabel?.text = "\(Int(progress * 100))%"
        }
    }
    
    @objc func resetFileStatus() {
        self.fileStatus.isHidden = false
        self.downloadStatusLabel?.text = ""
        self.fileDownloadIndicator?.isHidden = true
        let fileSize = message.getData()?.getAttachment()?.getFileInfo().getSize() ?? -1
        self.fileDescription?.text = FileMessage.byteCountFormatter.string(fromByteCount: fileSize)
        if self.documentDownloadTask?.isFileExist() ?? false {
            self.fileStatus.setBackgroundImage( UIImage(named: "FileDownloadSuccess")!, for: .normal )
        } else {
            self.fileStatus.setBackgroundImage( UIImage(named: "FileDownloadButton")!, for: .normal )
        }
        self.fileStatus.isUserInteractionEnabled = true
    }
    
    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            self.fileName?.textColor = buttonDefaultTitleColour
            self.fileDescription?.font = UIFont.systemFont(ofSize: 14)
            self.fileDescription?.textColor = editViewBackgroundColourDefault
        }
        return setup
    }
}
