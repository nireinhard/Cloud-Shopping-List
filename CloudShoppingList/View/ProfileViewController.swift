//
//  ProfileViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        AuthenticationController.logOutUser { (success) in
            if success{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
