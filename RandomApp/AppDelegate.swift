import UIKit

/// The "real" application delegate, the primary app delegate is used
/// to dispatch between test bundle and not.
public class AppDelegate {
    var window: UIWindow
    var httpClient: HTTPClient
    var randomClient: RandomClient

    // Inversion-of-control / Dependency Injection allows us to control
    // these values under test.
    public init(window: UIWindow, httpClient: HTTPClient) {
        self.window = window
        self.httpClient = httpClient
        randomClient = RandomClient(httpClient: httpClient, apiKey: RandomAPIKey)
    }

    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var rootController = ListViewController(client: randomClient)
        var navigationController = UINavigationController(rootViewController: rootController)
        window.rootViewController = navigationController
        return true
    }
}

// The application delegate. It simply dispatches to the "real" application
// delegate above, or just no-ops for test bundles.
@UIApplicationMain
class DispatchDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appDelegate: AppDelegate!

    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        var result = true
        if isTesting() {
            window?.rootViewController = UIViewController()
        } else {
            appDelegate = AppDelegate(window: window!, httpClient: URLConnectionHTTPClient())
            result = appDelegate.application(application,
                didFinishLaunchingWithOptions: launchOptions)
        }
        window?.makeKeyAndVisible()
        return result
    }

    private func isTesting() -> Bool {
        return NSClassFromString("XCTest") != nil
    }
}

