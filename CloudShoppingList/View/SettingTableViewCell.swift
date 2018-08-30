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
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(for userId: String, with status: Bool){
        User.loadUser(userId: userId, completion: { (user) in
            if let user = user{
             self.usernameLabel.text = user.username
             self.canEditSwitch.isOn = status
            }
        }) { }
    }

    @IBAction func canEditSwitchChanged(_ sender: Any) {
        
    }
}
