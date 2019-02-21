/*
*  This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
*  (c) 2016 Good Technology Corporation. All rights reserved.
*/

import UIKit

protocol FeedDownloadBaseDelegateProtocol : class {
    func downloadDone(_ data: Data?)
    func alert(_ alert: UIAlertController)
}

protocol FeedDownloadBaseReqeustProtocol : class {
    /* Requests the data from a specific URL. This can trigger SSL relaxation or authentication dialogs
    */
    func requestData(_ url: String);
    /* Aborts the current request at the HTTP level.
    */
    func abortRequest();
}

class FeedDownloadBase : NSObject, FeedDownloadBaseReqeustProtocol {
    weak var delegate: FeedDownloadBaseDelegateProtocol?

    internal var relaxCurrentSSL: Bool = false
    internal var currentURL: String?
    
    func requestData(_ url: String) {
        print("Base class requestData called")
        relaxCurrentSSL = false
        currentURL = url
    }
    
    func abortRequest() {
        print("Base class abortRequest called")
    }
}
