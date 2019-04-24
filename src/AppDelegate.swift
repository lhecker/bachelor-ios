import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let rootViewController = ViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)

        let window = UIWindow()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
        return true
    }
}
