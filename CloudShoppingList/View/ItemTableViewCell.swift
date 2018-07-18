//
//  ItemTableViewCell.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 18.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

protocol ItemCellDelegate: AnyObject{
    func buttonTapped(sender: ItemTableViewCell)
}

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var checkIcon: UIImageView!
    @IBOutlet weak var uncheckIcon: UIImageView!
    @IBOutlet weak var itemTextLabel: UILabel!
    @IBOutlet weak var addedByLabel: UILabel!
    
    weak var delegate: ItemCellDelegate?
    
    func configure(for item: Item, delegate: ItemCellDelegate){
        itemTextLabel.text = item.text
        addedByLabel.text = item.by
        
        if item.status{
            checkIcon.isHidden = true
            uncheckIcon.isHidden = false
        }else{
            checkIcon.isHidden = false
            uncheckIcon.isHidden = true
        }
        
        self.delegate = delegate
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
