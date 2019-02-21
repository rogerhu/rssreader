/*
*  This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
*  (c) 2016 Good Technology Corporation. All rights reserved.
*/

import Foundation

open class RSSFeed : NSObject, NSCoding {
    var rssName : String!
    var rssUrl : URL!
    
    fileprivate override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        self.rssName = (aDecoder.decodeObject(forKey: "rssName") as! String)
        self.rssUrl = (aDecoder.decodeObject(forKey: "rssUrl") as! URL)
    }
    
    convenience init(name rssName: String, url rssUrl: URL) {
        self.init()
        self.rssName = rssName
        self.rssUrl  = rssUrl
    }
 
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(rssName, forKey: "rssName")
        aCoder.encode(rssUrl, forKey: "rssUrl")
    }
}
