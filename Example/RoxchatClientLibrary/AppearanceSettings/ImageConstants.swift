
import Foundation
import UIKit

let closeButtonImage = #imageLiteral(resourceName: "CloseButton")
let fileButtonImage = #imageLiteral(resourceName: "AttachmentButton")
let loadingPlaceholderImage: UIImage! = UIImage(named: "ImagePlaceholder")
let navigationBarTitleImageViewImage = #imageLiteral(resourceName: "LogoRoxchatNavigationBar_dark")
let scrollButtonImage = #imageLiteral(resourceName: "SendMessageButton").flipImage(.vertically)
let textInputButtonImage = #imageLiteral(resourceName: "SendMessageButton")

let documentFileStatusImageViewImage = #imageLiteral(resourceName: "FileDownloadError")
let leadingSwipeActionImage =
    UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ?
        #imageLiteral(resourceName: "ReplyCircleToTheLeft") :
        #imageLiteral(resourceName: "ReplyCircleToTheLeft").flipImage(.horizontally)
let trailingSwipeActionImage =
    UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ?
        #imageLiteral(resourceName: "ReplyCircleToTheLeft").flipImage(.horizontally) :
        #imageLiteral(resourceName: "ReplyCircleToTheLeft")

let saveImageButtonImage = #imageLiteral(resourceName: "ImageDownload")

let documentFileStatusButtonDownloadOperator = #imageLiteral(resourceName: "FileDownloadButtonOperator")
let documentFileStatusButtonDownloadVisitor = #imageLiteral(resourceName: "FileDownloadButtonVisitor")
let documentFileStatusButtonDownloadError = #imageLiteral(resourceName: "FileDownloadError")
let documentFileStatusButtonDownloadSuccessOperator = #imageLiteral(resourceName: "FileDownloadSuccessOperator")
let documentFileStatusButtonDownloadSuccessVisitor = #imageLiteral(resourceName: "FIleDownloadSeccessVisitor")
let documentFileStatusButtonUploadVisitor = #imageLiteral(resourceName: "FileUploadButtonVisitor.pdf")
let userAvatarImagePlaceholder = #imageLiteral(resourceName: "HardcodedVisitorAvatar")
let messageStatusImageViewImageSent = #imageLiteral(resourceName: "Sent")
let messageStatusImageViewImageRead = #imageLiteral(resourceName: "ReadByOperator")

let replyImage = #imageLiteral(resourceName: "ActionReply")
let copyImage = #imageLiteral(resourceName: "ActionCopy")
let editImage = #imageLiteral(resourceName: "ActionEdit")
let deleteImage = #imageLiteral(resourceName: "ActionDelete").colour(actionColourDelete)

let selectedSurveyPoint = #imageLiteral(resourceName: "selectedSurveyPoint")
let unselectedSurveyPoint = #imageLiteral(resourceName: "unselectedSurveyPoint")
