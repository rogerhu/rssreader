/*
*  This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
*  (c) 2016 Good Technology Corporation. All rights reserved.
*/

import UIKit

open class RedToolbar : UIToolbar {
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.tintColor = maincolor()
    }
    
    override open func setItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        
        if let items = self.items {
            if items.count > 0 {
                let barButtonItem = items[0]
                let button = UIButton(type: .infoLight)
                button.addTarget(barButtonItem.target, action: barButtonItem.action!, for: .touchUpInside)
                barButtonItem.customView = button
            }
        }
    }
}
