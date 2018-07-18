//
//  ShoppingListTableViewCell.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

protocol ListCellDelegate: AnyObject{
    func buttonTapped(sender: ShoppingListTableViewCell)
}

class ShoppingListTableViewCell: UITableViewCell {

    @IBOutlet weak var shoppingListNameTextField: UILabel!
    @IBOutlet weak var memberInfoTextField: UILabel!
    
    weak var delegate: ListCellDelegate?
    var shoppingList: ListRepresentation?
    
    func configure(for shoppingList: ListRepresentation, delegate: ListCellDelegate){
        self.shoppingList = shoppingList
        self.shoppingListNameTextField.text = shoppingList.listName
        self.delegate = delegate
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func showDetailsButtonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(sender: self)
    }
}
