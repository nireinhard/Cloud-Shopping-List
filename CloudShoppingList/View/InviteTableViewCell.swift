//
//  InviteTableViewCell.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 19.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

protocol InviteCellDelegate: AnyObject{
    func buttonTapped(sender: InviteTableViewCell)
}

class InviteTableViewCell: UITableViewCell {
    
    weak var delegate: InviteCellDelegate?
    var user: User?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var alreadyInvitedLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(for user: User, list: ShoppingList, delegate: InviteCellDelegate){
        self.user = user
        self.delegate = delegate
        usernameLabel.text = user.username
        
        if let member = list.members[user.id] {
            inviteButton.isHidden = true
            inviteButton.isEnabled = false
            alreadyInvitedLabel.isHidden = false
            alreadyInvitedLabel.text = "Bereits eingeladen"
        }
        
    }
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(sender: self)
    }
    
}
