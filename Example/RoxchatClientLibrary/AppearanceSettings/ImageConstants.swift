
import Foundation
import UIKit

// ChatViewController.swift
let closeButtonImage = #imageLiteral(resourceName: "CloseButton")
let fileButtonImage = #imageLiteral(resourceName: "AttachmentButton")
let loadingPlaceholderImage = UIImage(named: "ImagePlaceholder")
let navigationBarTitleImageViewImage = UIImage(named: "LogoRoxchat")!
let scrollButtonImage = #imageLiteral(resourceName: "SendMessageButton").flipImage(.vertically)
let textInputButtonImage = #imageLiteral(resourceName: "SendMessageButton")
let networkErrorView = UIImage(named: "ConnectionImage")!
let uploadFileImage = UIImage(named: "FileUploadButtonVisitor")!
let readyFileImage = UIImage(named: "FileDownloadSuccess")!
let downloadFileImage = UIImage(named: "FileDownloadButton")!
let errorFileImage = UIImage(named: "FileDownloadError")!

// ChatTableViewController.swift
let documentFileStatusImageViewImage = #imageLiteral(resourceName: "FileDownloadError")
let leadingSwipeActionImage =
    UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ?
        #imageLiteral(resourceName: "ReplyCircleToTheLeft") :
        #imageLiteral(resourceName: "ReplyCircleToTheLeft").flipImage(.horizontally)
let trailingSwipeActionImage =
    UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ?
        #imageLiteral(resourceName: "ReplyCircleToTheLeft").flipImage(.horizontally) :
        #imageLiteral(resourceName: "ReplyCircleToTheLeft")

// ImageViewController.swift
let saveImageButton = #imageLiteral(resourceName: "ImageDownload")
let fileShare = #imageLiteral(resourceName: "FileShare")


// FlexibleTableViewCell.swift
let documentFileStatusButtonDownloadOperator = #imageLiteral(resourceName: "FileDownloadButtonOperator")
let documentFileStatusButtonDownloadVisitor = #imageLiteral(resourceName: "FileDownloadButtonVisitor")
let documentFileStatusButtonDownloadError = #imageLiteral(resourceName: "FileDownloadError")
let documentFileStatusButtonDownloadSuccessOperator = #imageLiteral(resourceName: "FileDownloadSuccessOperator")
let documentFileStatusButtonDownloadSuccessVisitor = #imageLiteral(resourceName: "FIleDownloadSeccessVisitor")
let documentFileStatusButtonUploadVisitor = #imageLiteral(resourceName: "FileUploadButtonVisitor.pdf")
let userAvatarImagePlaceholder = #imageLiteral(resourceName: "HardcodedVisitorAvatar")
let messageStatusImageViewImageSent = #imageLiteral(resourceName: "Sent")
let messageStatusImageViewImageRead = #imageLiteral(resourceName: "ReadByOperator")

// PopupActionTableViewCell.swift
let replyImage = #imageLiteral(resourceName: "ActionReply")
let copyImage = #imageLiteral(resourceName: "ActionCopy")
let editImage = #imageLiteral(resourceName: "ActionEdit")
let deleteImage = #imageLiteral(resourceName: "ActionDelete")

// SurveyRadioButtonViewController.swift
let selectedSurveyPoint = #imageLiteral(resourceName: "selectedSurveyPoint")
let unselectedSurveyPoint = #imageLiteral(resourceName: "unselectedSurveyPoint")
