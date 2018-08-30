//
//  SettingTableViewCell.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 21.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var canEditSwitch: UISwitch!
    @IBOutlet weak var usernameLabel: UILabel!
    var userId: String?
    var shoppingListId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(for userId: String, and shoppingListId: String, with status: Bool){
        self.userId = userId
        self.shoppingListId = shoppingListId
        User.loadUser(userId: userId, completion: { (user) in
            if let user = user{
                self.usernameLabel.text = user.username
            }
        }) {}
        self.canEditSwitch.isOn = status
        
    }

    @IBAction func canEditSwitchChanged(_ sender: Any) {
        if let userId = userId, let shoppingListId = shoppingListId{
            if canEditSwitch.isOn {
                ShoppingList.changePrivilige(for: userId, on: shoppingListId, newStatus: false)
                canEditSwitch.isOn = false
            }else{
                ShoppingList.changePrivilige(for: userId, on: shoppingListId, newStatus: true)
                canEditSwitch.isOn = true
            }
        }
    }
}
