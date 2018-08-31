//
//  MissingInfoViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 30.08.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

class MissingInfoViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty else {
            NotificationUtility.showPrettyMessage(with: "Bitte gib einen Benutzernamen ein", button: "ok", style: .error)
            return
        }
        User.addMissingInfo(for: Me.uid, with: username, completion: { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
