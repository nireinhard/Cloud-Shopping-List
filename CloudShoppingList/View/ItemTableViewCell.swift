//
//  ItemTableViewCell.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 18.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

protocol ItemCellDelegate: AnyObject{
    func buttonTapped(sender: ItemTableViewCell, check: Bool, itemId: String)
}

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var checkIcon: UIImageView!
    @IBOutlet weak var uncheckIcon: UIImageView!
    @IBOutlet weak var itemTextLabel: UILabel!
    @IBOutlet weak var addedByLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var uncheckButton: UIButton!
    
    var itemId: String?
    weak var delegate: ItemCellDelegate?
    
    func configure(for item: Item, with editStatus: Bool, delegate: ItemCellDelegate){
        itemTextLabel.text = item.text
        addedByLabel.text = item.by
        itemId = item.itemId
        
        if editStatus {
            if item.status{
                checkIcon.isHidden = true
                uncheckIcon.isHidden = false
                checkButton.isEnabled = false
                checkButton.isHidden = true
                uncheckButton.isEnabled = true
                uncheckButton.isHidden = false
            }else{
                // check icon is not hidden
                // uncheck icon is hidden
                // => not bought yet
                checkIcon.isHidden = false
                uncheckIcon.isHidden = true
                checkButton.isEnabled = true
                checkButton.isHidden = false
                uncheckButton.isEnabled = false
                uncheckButton.isHidden = true
            }
        }else{
            checkIcon.isHidden = true
            uncheckIcon.isHidden = true
        }
        
        self.delegate = delegate
    }
    
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(sender: self, check: true, itemId: itemId!)
    }
    
    @IBAction func uncheckButtonTapped(_ sender: Any) {
        delegate?.buttonTapped(sender: self, check: false, itemId: itemId!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
