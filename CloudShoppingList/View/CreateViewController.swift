//
//  CreateViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {

    @IBOutlet weak var newListTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        UIUtility.configureTextFields(textFields: [newListTextField], borderColor: UIColor.darkGray.cgColor)
    }

}
