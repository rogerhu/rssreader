/*
*  This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
*  (c) 2016 Good Technology Corporation. All rights reserved.
*/

import UIKit
import GD.SecureCommunication.Utility

public func RGB(_ r: Float, g: Float, b: Float) -> UIColor {
    return UIColor(red: CGFloat(r/255), green: CGFloat(g/255), blue: CGFloat(b/255), alpha: 1.0)
}

public func maincolor() -> UIColor {
    return RGB(77, g: 91, b: 103)
}

let kRSSTitle = "BBC World"
let kRSSUrl =  URL(string:"http://feeds.bbci.co.uk/news/world/rss.xml")
let kFeedSaveFile = "feedSaveFile.dat"

public func fullPathOfFile(name fileName: String) -> String {
    let libPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory,
                                                        FileManager.SearchPathDomainMask.userDomainMask,
                                                        true)
    let libPath = libPaths[0] as NSString
    let applicationDirectory = libPath.deletingLastPathComponent
    return (applicationDirectory + "/") + (fileName as String)
}

public func reachabilityStateOutputInfo() {
    let flags  = GDReachability.sharedInstance().status
    let strMsg = "GDReachabilityNotReachable = \((flags == .notReachable) ? "true" : "false"), GDReachabilityViaWiFi = \((flags == .viaWiFi) ? "true" : "false"), GDReachabilityViaCellular = \((flags == .viaCellular) ? "true" : "false")"
    NSLog(strMsg)
}

public func screenAccordingToOrientation() -> CGFloat {
    
    if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
        return UIScreen.main.bounds.size.height
    }
    
    return UIScreen.main.bounds.size.width
}

extension String {
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return boundingBox.height
    }
}
