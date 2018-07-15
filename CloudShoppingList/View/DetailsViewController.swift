//
//  DetailsViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var shoppingListNameLabel: UILabel!
    
    var shoppingList: ShoppingList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        if let list = shoppingList{
            shoppingListNameLabel.text = list.title
            navigationItem.title = list.title
        }
        // set back button color to white
        UINavigationBar.appearance().tintColor = .white
    }


}
