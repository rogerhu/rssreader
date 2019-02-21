/*
*  This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
*  (c) 2016 Good Technology Corporation. All rights reserved.
*/

import UIKit
import GD.SecureStore.File

private let actionCancelTitle = "Cancel"
private let actionSheetTitle = "Troubleshooting options"
private let actionSheetMessage = "You could upload or save logs"
private let uploadLogsActionTitle = "Upload Logs"
private let uploadLogsActionMessage = "A snapshot of your logs will be taken now and uploaded to the server for troubleshooting.\nThe upload process may take some time but it will continue in the background whenever possible until all the logs have been uploaded.\n Do you want to upload the logs now?"

class SWSettingsViewController: UIViewController {
    
    fileprivate var actionSheet : UIAlertController?
    fileprivate var alert:UIAlertController?
    
    @IBOutlet weak var troubleShootingButton: UIButton!
    
    @IBAction func troubleShootingPressed(_ sender: AnyObject) {
        self.showActionSheet()
    }
    
    @IBAction func dismissSettings(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func showActionSheet() {
        self.actionSheet = UIAlertController(title: actionSheetTitle, message: actionSheetMessage, preferredStyle: .actionSheet)
        
        self.actionSheet!.addAction(UIAlertAction(title: uploadLogsActionTitle, style: .default, handler: { action in
            self.showConformationAlertForActionName(uploadLogsActionTitle, actionMessage: uploadLogsActionMessage, actionHandler: {
                NSLog("logs uploading has been started...")
                GDLogManager.sharedInstance().startUpload()
            })
        }))
        
        if (UI_USER_INTERFACE_IDIOM() == .phone) {
            self.actionSheet!.addAction(UIAlertAction(title: actionCancelTitle, style: .cancel, handler: { action in
                self.actionSheet!.dismiss(animated: true, completion: { self.actionSheet = nil })
            }))
        } else {
            self.actionSheet!.modalPresentationStyle = .popover
            self.actionSheet!.popoverPresentationController?.sourceView = self.troubleShootingButton
        }
        
        self.present(self.actionSheet!, animated: true, completion: nil)
    }
    
    fileprivate func showConformationAlertForActionName(_ actionName: String, actionMessage: String, actionHandler: @escaping () -> Void ) {
        self.alert = UIAlertController(title: "\(actionName) ?", message: actionMessage, preferredStyle: .alert)
        self.alert!.addAction(UIAlertAction(title: actionName, style: .default, handler: {  action in
            actionHandler()
        }))
        self.alert!.addAction(UIAlertAction(title: actionCancelTitle, style: .cancel, handler: {  action in
            self.alert!.dismiss(animated: true, completion: { self.alert = nil })
        }))
        
        self.present(self.alert!, animated: true, completion: nil)
    }
}
