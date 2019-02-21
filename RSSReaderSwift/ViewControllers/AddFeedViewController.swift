/*
*  This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
*  (c) 2016 Good Technology Corporation. All rights reserved.
*/

import UIKit

open class SWAddFeedViewController : UIViewController, UITextFieldDelegate {
    
    var rssFeed : RSSFeed?
    
    fileprivate var alert : UIAlertController?
    
    @IBOutlet weak var feedNameTextField: UITextField!
    @IBOutlet weak var feedURLTextField: UITextField!
    @IBOutlet weak var addUpdateButton: UIButton!
    
    @IBAction func addFeed(_ sender: AnyObject?) {
        if (RSSManager.sharedRSSManager.save(rssFeed: self.rssFeed, feedName: self.feedNameTextField.text!, urlString: self.feedURLTextField.text!) == false) {
            self.alert = UIAlertController(title: "Feed Insert Error",
                message: "There was a problem with the new feed details\nPlease check that you have entered a name for the feed and a valid URL",
                preferredStyle: .alert)
            self.alert!.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in self.alert = nil }))
            self.present(self.alert!, animated: true, completion: nil)
            
        } else {
            
            let vc = self.navigationController?.popViewController(animated: true)
            print("Popped vc - ", String(describing: vc))
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (rssFeed == nil) {
            self.title = "Add RSS Feed"
            addUpdateButton.setTitle("Add feed", for: UIControlState())
        } else {
            self.title = "Edit RSS Feed"
            addUpdateButton.setTitle("Update feed", for: UIControlState())
            
            feedURLTextField.text = rssFeed!.rssUrl.absoluteString
            feedNameTextField.text = rssFeed!.rssName
        }
        
        feedNameTextField.delegate = self
        feedURLTextField.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.feedNameTextField.resignFirstResponder()
        self.feedURLTextField.resignFirstResponder()
        
        feedNameTextField.delegate = nil
        feedURLTextField.delegate = nil
    }
    
    // This allows the user to tab through to the Next UITextField
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTeg = textField.tag + 1
        
        let responder = textField.superview?.viewWithTag(nextTeg)
        if ((responder) != nil) {
            responder?.becomeFirstResponder()
        } else {
            self.addFeed(nil)
        }
        
        return false; // We do not want UITextField to insert line-breaks.
    }
}
