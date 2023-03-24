
import UIKit

extension NotificationCenter {
    
    func postInMainThread(name aName: NSNotification.Name, object anObject: Any?) {
        DispatchQueue.main.async {
            self.post(name: aName, object: anObject)
        }
    }
    
    func postInMainThread(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable: Any]? = nil) {
        DispatchQueue.main.async {
            self.post(name: aName, object: anObject, userInfo: aUserInfo)
        }
    }
    
}
