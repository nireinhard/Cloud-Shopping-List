//
//  CreateViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateViewController: UIViewController {

    @IBOutlet weak var createListButton: RoundedButton!
    @IBOutlet weak var newListTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        UIUtility.configureTextFields(textFields: [newListTextField], borderColor: UIColor.darkGray.cgColor)
    }
    
    @IBAction func createListButtonTapped(_ sender: RoundedButton) {
        createListButton.isEnabled = false
        
        guard let listname = newListTextField.text, !listname.isEmpty else{
            NotificationUtility.showPrettyMessage(with: "Bitte gib einen Namen für den Einkaufszettel ein", button: "Ok", style: .error)
            createListButton.isEnabled = true
            return
        }
        
        SVProgressHUD.show()
        ShoppingList.createShoppingList(title: listname) {
            SVProgressHUD.dismiss()
            self.createListButton.isEnabled = true
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    //Tastatur ausblenden mit Touch ausserhalb der Tastatur
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
