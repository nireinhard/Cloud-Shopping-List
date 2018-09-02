//
//  TabViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import SwiftyJSON

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationListenerController.shared.startListening {
            if NotificationListenerController.shared.notifications.count != 0{
                self.tabBar.items?[1].badgeValue = "\(NotificationListenerController.shared.notifications.count)"
            }
        }
        
        FirebaseHelper.getRealtimeDB().child("users").child(Me.uid).observe(.value) { (snapshot) in
            let data = JSON(snapshot.value).dictionaryValue
            if data["metadata"] == nil {
                self.performSegue(withIdentifier: "missingInfoSegue", sender: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
