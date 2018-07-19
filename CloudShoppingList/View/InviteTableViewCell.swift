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
        if let userlists = user.lists{
            inviteButton.isHidden = false
            alreadyInvitedLabel.isHidden = true
            
            print("userlists: \(userlists)")
            
            for userlist in userlists{
                if userlist.listId == list.listId{
                    inviteButton.isHidden = true
                    alreadyInvitedLabel.isHidden = false
                    alreadyInvitedLabel.text = "Bereits eingeladen"
                    break
                }
            }
        }
    }
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(sender: self)
    }
    
}
