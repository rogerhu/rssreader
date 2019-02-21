/*
*  This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
*  (c) 2016 Good Technology Corporation. All rights reserved.
*/

import UIKit
import GD

class SWFeedsViewController : UITableViewController {
    
    fileprivate var alert : UIAlertController?
    fileprivate var detailedViewController : UINavigationController? {
        get {
            return (self.splitViewController?.viewControllers.last)! as? UINavigationController
        }
    }
    fileprivate func toolbarVisible(forTraitCollection tc: UITraitCollection) -> Bool {
        return tc.userInterfaceIdiom == .pad || (tc.horizontalSizeClass == .regular && tc.verticalSizeClass == .compact)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.toolbar.isHidden = self.toolbarVisible(forTraitCollection: self.traitCollection)
        self.detailedViewController!.navigationBar.tintColor = maincolor()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationController?.navigationBar.tintColor = UIColor(red: 77.0/255.0, green: 91.0/255.0, blue: 103.0/255.0, alpha: 1.0)
        
        NotificationCenter.default.addObserver(self.tableView!,
            selector:#selector(UITableView.reloadData),
            name:NSNotification.Name(rawValue: kRSSFeedAddedNotification),
            object: nil)
		
        if (!GDReachability.sharedInstance().isNetworkAvailable) {
            self.showAlertWithMessage("Network is NOT Available")
        }
		
        NotificationCenter.default.addObserver(self,
			selector: #selector(SWFeedsViewController.reachabilityChanged(_:)),
			name: NSNotification.Name.GDReachabilityChanged,
			object: GDiOS.sharedInstance())
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self.tableView!)
    }

    fileprivate func showAlertWithMessage(_ actionMessage: String) {
        self.alert = UIAlertController(title: "Reachability state", message: actionMessage, preferredStyle: .alert)
        self.alert!.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(self.alert!, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "editFeedSegue":
            let feed = RSSManager.sharedRSSManager.feedAt((self.tableView.indexPath(for: sender as! UITableViewCell)?.row)!)!
            let vc : SWAddFeedViewController = segue.destination as! SWAddFeedViewController
            vc.rssFeed = feed
            
        case "openFeedSegue":
            let feed = RSSManager.sharedRSSManager.feedAt((self.tableView.indexPath(for: sender as! UITableViewCell)?.row)!)!
            let vc : SWFeedViewController = segue.destination as! SWFeedViewController
            vc.rssFeed = feed

        default: break
        }
    }
    
    override func targetViewController(forAction action: Selector, sender: Any?) -> UIViewController? {
        if !self.toolbarVisible(forTraitCollection: self.traitCollection) {
            self.detailedViewController!.popToRootViewController(animated: false)
            return self.detailedViewController
        }
        return super.targetViewController(forAction: action, sender: sender)
    }
    
    // MARK: - Table view data source and delegate implementation
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RSSManager.sharedRSSManager.numberOfFeeds
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedUrlTableViewCell")
        
        if let feed = RSSManager.sharedRSSManager.feedAt(indexPath.row) {
            cell?.textLabel?.text = feed.rssName
            cell?.detailTextLabel?.text = feed.rssUrl.absoluteString
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.showFeedAtIndexPath(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            tableView.beginUpdates()
            
            RSSManager.sharedRSSManager.removeFeed(atPos: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.endUpdates()
        }
    }
    
    func showFeedAtIndexPath(_ indexPath: IndexPath) {
        if  UIDevice.current.userInterfaceIdiom == .pad {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let feedVC : SWFeedViewController = storyboard.instantiateViewController(withIdentifier: "feedViewController") as! SWFeedViewController
            feedVC.rssFeed = RSSManager.sharedRSSManager.feedAt(indexPath.row)
            
            self.detailedViewController?.viewControllers = [feedVC]
        } else {
            self.performSegue(withIdentifier: "openFeedSegue", sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    // MARK: - Reachability observing
    
    @objc func reachabilityChanged(_ notification: Notification) {
        let flags = GDReachability.sharedInstance().status
        let message = "NotReachable = \(flags == .notReachable ? "true" : "false"), ViaWiFi = \(flags == .viaWiFi ? "true" : "false"), ViaCellular = \(flags == .viaCellular ? "true" : "false")"
        self.showAlertWithMessage(message)
    }
}
