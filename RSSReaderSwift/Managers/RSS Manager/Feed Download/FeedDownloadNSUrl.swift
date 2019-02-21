/*
*  This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
*  (c) 2016 Good Technology Corporation. All rights reserved.
*/

import UIKit
import GD

class FeedDownloadNSUrl : FeedDownloadBase, URLSessionTaskDelegate {
    
    fileprivate var urlSession : Foundation.URLSession!
    fileprivate var dataBuffer : NSMutableData
    fileprivate var isRelaxSSL : Bool = false
    
    override init() {
        dataBuffer = NSMutableData()
        super.init()
    }
    
    // With K-series for NSURLSession, only requests without authentication are supported for making secured connections throw GC/GP
    override func requestData(_ url: String) {
        super.requestData(url)
        self.requestData(url, relaxSSL: relaxCurrentSSL)
    }
    
    
    func requestData(_ url: String, relaxSSL: Bool) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // With K-series for NSURLSession, only shared session is supported for making secured connections throw GC/GP
        
        self.isRelaxSSL = relaxSSL;
        self.dataBuffer.length = 0
        
        let config = URLSessionConfiguration.default;
        self.urlSession = Foundation.URLSession.init(configuration: config, delegate: self, delegateQueue: nil);
        
        NSLog("Create task");
        
        // With K-series for NSURLSession, only data tasks with completionHandler are supported for making secured connections throw GC/GP
        let task = self.urlSession.dataTask(with: URL(string: self.currentURL!)!) { (data: Data?, response: URLResponse?, error: Error?) in
            NSLog("Task completionHandler");
            
            if (error != nil) {
                let alert = UIAlertController(title: "Error Fetching File", message: String(describing: error), preferredStyle: UIAlertControllerStyle.alert)
                
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction :UIAlertAction) -> Void in
                    self.delegate?.downloadDone(nil)
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(alertAction)
                self.delegate?.alert(alert)
                
            } else {
                self.dataBuffer.append(data!)
                self.delegate?.downloadDone(self.dataBuffer as Data)
                self.dataBuffer.length = 0
            }
        }
        
        task.resume()
    }
    
    override func abortRequest() {
        super.abortRequest()
        
        // cancel the session
        urlSession.invalidateAndCancel()
        
        // switch off the activity indicator here as the normal loading flow will be halted
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        NSLog("session task didReceiveChallenge");
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        NSLog("session didReceiveChallenge");
        
        let authMethod = challenge.protectionSpace.authenticationMethod;
        
        if ((NSURLAuthenticationMethodHTTPBasic == authMethod) ||
            (NSURLAuthenticationMethodHTTPDigest == authMethod) ||
            (NSURLAuthenticationMethodNTLM == authMethod) ||
            (NSURLAuthenticationMethodNegotiate == authMethod)) {

            NSLog("authMethod = %@", authMethod);
            self.displayAuthQueryDialog(challenge, completionHandler: completionHandler)
            
        } else if (NSURLAuthenticationMethodClientCertificate == authMethod) {
        // do nothing - GD will automatically supply an appropriate client certificate
        } else if (NSURLAuthenticationMethodServerTrust == authMethod) {
            // check SSL relaxation
            if (self.isRelaxSSL) {
                let credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential);
            }
            
        } else {
            // this application doesn't support the specified method
            self.delegate?.downloadDone(nil)
        }
        
        // reset the buffer
        self.dataBuffer.length = 0
    }
    
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data) {
        self.dataBuffer.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async(execute: {
            if (error != nil) {
                guard let error = error as NSError? else {return}
                let code = error.code as Int;
                if (NSURLErrorServerCertificateUntrusted == code) {
                    self.displaySSLQueryDialog()
                } else {
                    // display a dialog
                    let alert = UIAlertController(title: "Error Fetching File", message: String(describing: error), preferredStyle: UIAlertControllerStyle.alert)
                    let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction :UIAlertAction) -> Void in
                        self.delegate?.downloadDone(nil)
                        alert.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(alertAction)
                    self.delegate?.alert(alert)
                }
            } else {
                self.delegate?.downloadDone(self.dataBuffer as Data);
                
                // reset the buffer
                self.dataBuffer.length = 0
            }
        });
    }
    
    /*
     * This method displays a dialog allowing the user allow relaxation of certificate verification
     */
    fileprivate func displaySSLQueryDialog() {
        
        let alert = UIAlertController(title: "Enter ID and Password", message: "Relax certificate verification for this site ?\n", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (alAction : UIAlertAction) -> Void in
            
            self.isRelaxSSL = true;
            self.requestData(self.currentURL!, relaxSSL: self.relaxCurrentSSL)
        }
        
        let cancelAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (alAction :UIAlertAction) -> Void in
            
        }
        
        alert.addAction(okAlertAction)
        alert.addAction(cancelAlertAction)
        self.delegate?.alert(alert)
    }
    
    /*
     * This method displays a dialog allowing the user to enter a user id and password
     */
    fileprivate func displayAuthQueryDialog(_ challenge: URLAuthenticationChallenge, completionHandler: (Foundation.URLSession.AuthChallengeDisposition, URLCredential?)->Void) {
        
        let alert = UIAlertController(title: "Enter ID and Password", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAlertAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.default) { ( _ ) -> Void in
            let usernameTextField = alert.textFields![0] as UITextField
            let passwordTextFiled = alert.textFields![1] as UITextField
            
            let credentials = URLCredential(user: usernameTextField.text!, password: passwordTextFiled.text!,persistence: URLCredential.Persistence.forSession)
            challenge.sender?.use(credentials, for: challenge)
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alAction : UIAlertAction) -> Void in
            challenge.sender?.continueWithoutCredential(for: challenge)
        }
        
        alert.addAction(okAlertAction)
        alert.addAction(cancelAlertAction)
        
        alert.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "Username"
        }
        
        alert.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        self.delegate?.alert(alert)
    }
    
}
