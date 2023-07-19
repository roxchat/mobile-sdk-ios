
import Foundation

/**
 Errors that can be received from a server after a HTTP-request.
 */
enum RoxchatInternalError: String, Error {
    case accountBlocked = "account-blocked"
    case chatRequired = "chat-required"
    case contentTypeNotRecognized = "content_type_not_recognized"
    case domainNotFromWhitelist = "domain-not-from-whitelist"
    case fileSizeExceeded = "max_file_size_exceeded"
    case fileSizeTooSmall = "file_size_too_small"
    case fileTypeNotAllowed = "not_allowed_file_type"
    case notAllowedMimeType = "not_allowed_mime_type"
    case noPreviousChats = "no_previous_chats"
    case noStickerId = "no-sticker-id"
    case notMatchingMagicNumbers = "not_matching_magic_numbers"
    case maxFilesCountPerChatExceeded = "max_files_count_per_chat_exceeded"
    case providedVisitorFieldsExpired = "provided-visitor-expired"
    case reinitializationRequired = "reinit-required"
    case settingDisabled = "setting_disabled"
    case serverNotReady = "server-not-ready"
    case sessionNotFound = "session_not_found"
    case unauthorized = "unauthorized"
    case uploadedFileNotFound = "uploaded-file-not-found"
    case visitorBanned = "visitor_banned"
    case wrongArgumentValue = "wrong-argument-value"
    case wrongProvidedVisitorFieldsHashValue = "wrong-provided-visitor-hash-value"
    
    // Data errors
    // Quoting message errors
    case quotedMessageCannotBeReplied = "quoting-message-that-cannot-be-replied"
    case quotedMessageFromAnotherVisitor = "quoting-message-from-another-visitor"
    case quotedMessageCorruptedID = "corrupted-quoted-message-id"
    case quotedMessageMultipleID = "multiple-quoted-messages-found"
    case quotedMessageNotFound = "quoted-message-not-found"
    case quotedMessageRequiredArgumentsMissing = "required-quote-args-missing"
    
    // Provided authonication token errors
    case providedAuthenticationTokenNotFound = "provided-auth-token-not-found"
    
    // Send, edit and delete message errors.
    // send or edit:
    case messageEmpty = "message_empty"
    case maxMessageLengthExceeded = "max-message-length-exceeded"
    // delete:
    case messageNotFound = "message_not_found"
    // edit or delete
    case notAllowed = "not_allowed"
    case messageNotOwned = "message_not_owned"
    // edit
    case wrongMessageKind = "wrong_message_kind"
    
    // Rate operator errors
    case noChat = "no-chat"
    case operatorNotInChat = "operator-not-in-chat"
    case noteIsTooLong = "note-is-too-long"
    
    // Keyboard response errors
    case buttonIdNotSet = "button-id-not-set"
    case requestMessageIdNotSet = "request-message-id-not-set"
    case canNotCreateResponse = "cannot-create-response"
    case canNotCreateResponseOld = "can-not-create-response"
    
    // Send Dialog errors
    case sentTooManyTimes = "chat-history-sent-too-many-times"
    
    //Survey errors
    case surveyDisabled = "survey_disabled"
    case noCurrentSurvey = "no-current-survey"
    case incorrectSurveyID = "incorrect-survey-id";
    case incorrectStarsValue = "incorrect-stars-value"
    case incorrectRadioValue = "incorrect-radio-value"
    case maxCommentLenghtExceeded = "max-comment-length-exceeded"
    case questionNotFound = "question-not-found"
    
    //Errors for Delete files
    case fileHasBeenSent = "file-has-been-sent"
    case fileNotFound = "file-not-found"
    
    // Geolocation errors
    case invalidCoordinatesReceived = "invalid-coordinates-received"
}
