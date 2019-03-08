/*
*  This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
*  (c) 2016 Good Technology Corporation. All rights reserved.
*/

import UIKit
import GD.Runtime
import GD.AuthenticationToken

let kServiceID = "com.hearsaysystems.relatetest"
let kServiceVersion = "1.0.0.0"

class SWAboutViewController : UIViewController, GDAuthTokenDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var getSAMLBtn: UIButton!
    @IBOutlet weak var getGoodBtn: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var goodToken: String?
    var samlToken: String?
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = " - GD SDK integration working fine. \n\n - Good authorization success."
        activity.isHidden = true
    }
    
    @IBAction func close(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func onGDAuthTokenSuccess(_ gdAuthToken: String) {
        goodToken = gdAuthToken
        DispatchQueue.main.async {
            self.activity.stopAnimating()
            self.updateLogWith("- Good token generated. GoodToken = \(gdAuthToken)")
        }
    }
    
    func onGDAuthTokenFailure(_ authTokenError: Error) {
        goodToken = nil
        DispatchQueue.main.async {
            self.activity.stopAnimating()
            self.updateLogWith("- Error generating Good token. Error = \(authTokenError.localizedDescription)")
        }
    }
    
    @IBAction func generateGoodToken(_ sender: Any) {
        activity.startAnimating()
        updateLogWith("- Generate Good Token.")
        
        let gdutility = GDUtility()
        gdutility.gdAuthDelegate = self
        gdutility.getGDAuthToken("", serverName: getGDTokenServer())
    }
    
    private func getGDTokenServer() -> String? {
        let serviceProviders = GDiOS.sharedInstance().getServiceProviders(for: kServiceID,
                                                                          andVersion: kServiceVersion,
                                                                          andServiceType: .server)
        guard serviceProviders.count > 0,
            let appServer = serviceProviders.first?.serverCluster.first,
            let server = appServer.server,
            let port = appServer.port else {
            updateLogWith("- No GD token app server found.")
            return nil
        }
        let tokenLookupURL = "https://\(server):\(port)/api/lookupuser"
        return tokenLookupURL
    }
    
    @IBAction func getSAMLToken(_ sender: Any) {
        activity.startAnimating()
        updateLogWith("- SAML token generation started.")
        
        var ssoHeaders = [String : String]()
        ssoHeaders["BB Token"] = goodToken
        ssoHeaders["app-id"] = kServiceID
        ssoHeaders["app-version"] = kServiceVersion
        ssoHeaders["Accept"] = "application/json"
        ssoHeaders["Content-Type"] = "application/json"
        
        doPost(urlString: "https://mydev.wellsfargo.com/AuthServicesInternal/Mobile/GenericServletSSO",
               parameters: nil,
               customHeaders: ssoHeaders,
               success: { (resp, respData) in
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.updateLogWith("- SAML token generation succeeded.")
                    if let responseDict = respData as? [String: AnyObject],
                        let saml = responseDict["SAMLResponse"] as? String {
                        self.updateLogWith("- SAML token = \(saml)")
                        self.samlToken = saml
                    }
                }
        }) { (error) in
            DispatchQueue.main.async {
                self.activity.stopAnimating()
                self.updateLogWith("- SAML token generation failed. Error = \(error.localizedDescription).")
            }
        }
    }
    
    private func updateLogWith(_ newlog: String) {
        var log = textView.text
        log = "\(log ?? "") \n\n \(newlog)"
        textView.text = log
    }
    
    private func configureURLRequest(urlString: String,
                                     customHeaders: [String : String]?) -> URLRequest? {
        guard let serviceURL = URL(string: urlString) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: serviceURL)
        if let custHeaders = customHeaders {
            for (k, v) in custHeaders {
                urlRequest.setValue(v, forHTTPHeaderField: k)
            }
        }
        return urlRequest
    }
    
    func doPost(urlString: String,
                parameters: Any?,
                customHeaders: [String : String]?,
                success: ((URLResponse?, Any) -> Void)?,
                failure: ((Error) -> Void)?)  {
        guard var urlRequest = configureURLRequest(urlString: urlString, customHeaders: customHeaders) else {
            return
        }
        
        urlRequest.httpMethod = "POST"
        if let postBodyStr = parameters as? String,
            let jsonData = postBodyStr.data(using: .utf8) {
            urlRequest.httpBody = jsonData
        } else if let params = parameters {
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
                urlRequest.httpBody = jsonData
            } catch {
                return
            }
        } else {
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard let responseData = data else {
                success?(response, data as AnyObject)
                return
            }
            
            do {
                let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: [])
                success?(response, responseJSON)
            } catch  {
                success?(response, data as AnyObject)
                return
            }
        }
        task.resume()
    }
}
