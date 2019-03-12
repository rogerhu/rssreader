/*
*  This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
*  (c) 2016 Good Technology Corporation. All rights reserved.
*/

import UIKit
import GD.Runtime
import GD.AuthenticationToken

let kDefaultServiceID = "com.hearsaysystems.relatetest" // "com.good.gdservice.enterprise.directory"
let kDefaultVersion = "1.0.0.0"
private let kInvalidRespStr = NSLocalizedString("INVALID_RESPONSE", value: "Invalid server response.", comment: "")
private let kInvalidRespError = NSError(domain: "Error", code: 999, userInfo: [NSLocalizedDescriptionKey : kInvalidRespStr])

class SWAboutViewController : UIViewController, GDAuthTokenDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var getSAMLBtn: UIButton!
    @IBOutlet weak var getGoodBtn: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var gdApplicationId = kDefaultServiceID
    var gdApplicationVersion = kDefaultVersion
    var goodToken: String?
    var samlToken: String?
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = " - GD SDK integration working fine. \n\n - Good authorization success."
        activity.isHidden = true
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
        }
        gdApplicationId = nsDictionary?.object(forKey: "GDApplicationID") as? String ?? kDefaultServiceID
        gdApplicationVersion = nsDictionary?.object(forKey: "GDApplicationVersion") as? String ?? kDefaultVersion
    }
    
    @IBAction func close(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func onGDAuthTokenSuccess(_ gdAuthToken: String) {
        goodToken = gdAuthToken
        DispatchQueue.main.async {
            self.activity.stopAnimating()
            Logger.shared.log(level: .Info, message: "Good Token  = \(gdAuthToken)")
            self.updateLogWith("- Good token generated. \nGoodToken = \(gdAuthToken)")
        }
    }
    
    func onGDAuthTokenFailure(_ authTokenError: Error) {
        goodToken = nil
        DispatchQueue.main.async {
            self.activity.stopAnimating()
            Logger.shared.log(level: .Info, message: "Good Token generation failed. Error = \(authTokenError.localizedDescription)")
            self.updateLogWith("- Error generating Good token. Error = \(authTokenError.localizedDescription)")
        }
    }
    
    @IBAction func generateGoodToken(_ sender: Any) {
        activity.startAnimating()
        updateLogWith("- Generate Good Token.")
        
        let gdutility = GDUtility()
        gdutility.gdAuthDelegate = self
        gdutility.getGDAuthToken("", serverName: " ")
    }
    
    @IBAction func getSAMLToken(_ sender: Any) {
        activity.startAnimating()
        Logger.shared.log(level: .Info, message: "SAML service called.")
        updateLogWith("- SAML token generation started.")
        
//        let ssoURL = "https://mydev.wellsfargo.com/AuthServicesInternal/Mobile/GenericServletSSO"
        let ssoURL = "https://mydev.advisor-connection.com/AuthServicesInternal/Mobile/GenericServletSSO"
        var ssoHeaders = [String : String]()
        ssoHeaders["GoodToken"] = goodToken
        ssoHeaders["clientAppId"] = "Hearsay"
        ssoHeaders["Accept"] = "application/json"
        ssoHeaders["Content-Type"] = "application/json"
        
        doPost(urlString: ssoURL,
               parameters: nil,
               customHeaders: ssoHeaders,
               success: { (resp, respData) in
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    Logger.shared.log(level: .Info, message: "SAML service response received.")
                    self.updateLogWith("- SAML token generation succeeded.")
                    if let responseDict = respData as? [String: AnyObject],
                        let saml = responseDict["SAMLResponse"] as? String {
                        Logger.shared.log(level: .Info, message: "SAML Token = \(saml)")
                        self.updateLogWith("- SAML token = \(saml)")
                        self.samlToken = saml
                    }
                }
        }) { (error) in
            DispatchQueue.main.async {
                self.activity.stopAnimating()
                Logger.shared.log(level: .Error, message: "SAML token generation failed. Error = \(error.localizedDescription).")
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
        
        Logger.shared.log(level: .Info, message: "POST URL : \(urlRequest.url?.absoluteString ?? "")")
        Logger.shared.log(level: .Info, message: "POST Headers : \(urlRequest.allHTTPHeaderFields as AnyObject)")
        
        if let postBodyStr = parameters as? String,
            let jsonData = postBodyStr.data(using: .utf8) {
            urlRequest.httpBody = jsonData
            Logger.shared.log(level: .Info, message: "POST Body = \(postBodyStr)")
        } else if let params = parameters {
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
                urlRequest.httpBody = jsonData
                Logger.shared.log(level: .Info, message: "POST Body = \(params as AnyObject)")
            } catch {
                return
            }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard let response = response as? HTTPURLResponse else {
                Logger.shared.log(level: .Error, message: "[🚩] Bad response.")
                failure?(kInvalidRespError)
                return
            }
            Logger.shared.log(level: .Info, message: "POST Response Status : \(response.statusCode)")
            
            guard let responseData = data else {
                Logger.shared.log(level: .Error, message: "[🚩] No data in response. Probable packet loss.")
                success?(response, data as AnyObject)
                return
            }
            
            do {
                let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: [])
                Logger.shared.log(level: .Info, message: "POST Response Body: \((responseJSON as AnyObject))")
                success?(response, responseJSON)
            } catch  {
                Logger.shared.log(level: .Info, message: "[🚩] Invalid JSON response.")
                success?(response, data as AnyObject)
                return
            }
        }
        task.resume()
    }
}
