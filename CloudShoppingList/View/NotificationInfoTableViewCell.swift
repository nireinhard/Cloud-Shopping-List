//
//  NotificationInfoTableViewCell.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 12.09.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

protocol ReadActionDelegate: AnyObject{
    func readTapped(notification: Notification)
}

class NotificationInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    var notification: Notification?
    weak var delegate: ReadActionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(notification: Notification, delegate: ReadActionDelegate){
        self.notification = notification
        self.delegate = delegate
        messageLabel.text = notification.message
    }
    
    @IBAction func readButtonTapped(_ sender: UIButton) {
        if let notification = notification{
            delegate?.readTapped(notification: notification)
        }
    }
}
