
import UIKit

class NavigationBarUpdater {

    static let shared = NavigationBarUpdater()

    private var canUpdateBar: Bool = true
    private var isBarVisible: Bool?
    private var navigationController: UINavigationController?

    func update(with style: NavigationBarStyle) {
        guard canUpdateBar else { return }

        let isEnabled: Bool = false
        let isTranslucent: Bool = false
        let barTintColor: UIColor = navigationBarTintColour
        var backgroundColor: UIColor

        switch style {
        case .connected:
            backgroundColor = navigationBarBarTintColour
        case .disconnected:
            backgroundColor = navigationBarNoConnectionColour
        case .clear:
            backgroundColor = navigationBarClearColour
        case .defaultStyle:
            backgroundColor = navigationBarBarTintColour
        }

        navigationController?.setTopBar(
            isEnabled: isEnabled,
            isTranslucent: isTranslucent,
            barTintColor: barTintColor,
            backgroundColor: backgroundColor)
    }

    func setupNavigationBar() {
        // Fixing 'shadow' on top of the main colour
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    func set(canUpdate: Bool) {
        canUpdateBar = canUpdate
    }

    func set(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func set(isNavigationBarVisible: Bool) {
        isBarVisible = isNavigationBarVisible
        navigationController?.setNavigationBarHidden(!isNavigationBarVisible, animated: true)
    }

    func isNavigationBarVisible() -> Bool {
        return isBarVisible == true
    }

}

enum NavigationBarStyle {
    case connected
    case disconnected
    case clear
    case defaultStyle
}
