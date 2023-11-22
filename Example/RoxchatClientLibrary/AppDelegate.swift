
import UIKit
import RoxchatClientLibrary
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    var window: UIWindow?
    static var shared: AppDelegate!
    lazy var isApplicationConnected: Bool = false
    
    private var notificationUserInfo: [AnyHashable: Any]?
    
    // MARK: - Methods
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.shared = self
        UNUserNotificationCenter.current().delegate = self
        // Remote notifications configuration
        let notificationTypes: UNAuthorizationOptions = [.alert,
                                                         .badge,
                                                         .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: notificationTypes) { (granted, error) in
            if granted {
                // application.registerUserNotificationSettings(remoteNotificationSettings)
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    application.applicationIconBadgeNumber = 0
                }
            } else {
                print(error ?? "Error with remote notification")
            }
        }

        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        WMKeychainWrapper.standard.setString(deviceToken, forKey: WMKeychainWrapper.deviceTokenKey)
        
        print("Device token: \(deviceToken)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
    }
    
    static var keyboardWindow: UIWindow? {
        
        let windows = UIApplication.shared.windows
        if let keyboardWindow = windows.first(where: { NSStringFromClass($0.classForCoder) == "UIRemoteKeyboardWindow" }) {
          return keyboardWindow
        }
        return nil
    }
    
    static func keyboardHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            AppDelegate.keyboardWindow?.isHidden = hidden
        }
    }
    
    static func checkMainThread() {
        if !Thread.isMainThread {
#if DEBUG
            fatalError("Not main thread error")
#else
            print("Not main thread error")
#endif
        }
    }

    private func openChatFromNotification(_ notificationUserInfo: [AnyHashable: Any]) {
        // ROXCHAT: Remote notification handling.
        if Roxchat.isRoxchat(remoteNotification: notificationUserInfo) {
            _ = Roxchat.parse(remoteNotification: notificationUserInfo)
            // Handle Roxchat remote notification.
            guard !isChatIsTopViewController() else { return }

            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: false)
                guard let startViewController = navigationController.viewControllers.first as? WMStartViewController else { return }
                startViewController.startChat()
            }
        } else {
            // Handle another type of remote notification.
        }
    }

    private func isChatIsTopViewController() -> Bool {
        guard let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return false }
        return navigationController.viewControllers.last?.isChatViewController == true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        notificationUserInfo = notification.request.content.userInfo
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        if let notificationUserInfo = notificationUserInfo {
            openChatFromNotification(notificationUserInfo)
        }
        
        completionHandler()
    }
}
