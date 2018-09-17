//
//  NotificationInvitationTableViewCell.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 19.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

protocol InvitationActionDelegate: AnyObject{
    func acceptedTapped(notification: Notification)
    func declinedTapped(notification: Notification)
}

class NotificationInvitationTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    var notification: Notification?
    weak var delegate: InvitationActionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(notification: Notification, delegate: InvitationActionDelegate){
        self.notification = notification
        self.delegate = delegate
        messageLabel.text = notification.message
    }
    
    @IBAction func acceptButtonTapped(_ sender: RoundedButton) {
        if let notification = notification{
             delegate?.acceptedTapped(notification: notification)
        }
    }
    
    @IBAction func declineBUuttonTapped(_ sender: RoundedButton) {
        if let notification = notification{
            delegate?.declinedTapped(notification: notification)
        }
    }
    
}
