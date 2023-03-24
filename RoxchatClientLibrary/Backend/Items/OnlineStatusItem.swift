
import Foundation

/**
 Raw values equal to field names received in responses from server (except `unknown` case which is custom).
 * `busyOffline` - user can't send messages at all;
 * `busyOnline` - user send offline messages, but server can return an error;
 * `offline` - user can send offline messages;
 * `online` - user can send online and offline messages;
 * `unknown` - session has not received data from server.
 */
enum OnlineStatusItem: String {
    case busyOffline = "busy_offline"
    case busyOnline = "busy_online"
    case offline = "offline"
    case online = "online"
    case unknown = "unknown"
}
