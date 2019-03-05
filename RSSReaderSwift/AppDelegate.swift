/*
 * (c) 2016 BlackBerry Limited. All rights reserved.
 *
 */

import UIKit
import GD.Runtime
import GD.AuthenticationToken


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GDAuthTokenDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        RSSReaderGDiOSDelegate.sharedInstance.appDelegate = self
        GDiOS.sharedInstance().authorize(RSSReaderGDiOSDelegate.sharedInstance)
        
        return true
    }
    
    func didAuthorize() -> Void {
//        let gdutility = GDUtility()
//        gdutility.gdAuthDelegate = self
//        gdutility.getGDAuthToken("Hearsay", serverName: "")

    }
    
    public func onGDAuthTokenSuccess(_ gdAuthToken: String) {
        print("*** GoodToken = \(gdAuthToken)")
    }
    
    func onGDAuthTokenFailure(_ authTokenError: Error) {
        print("Error = \(authTokenError.localizedDescription)")
    }
}
