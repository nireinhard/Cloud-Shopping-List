//
//  RegisterViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import SVProgressHUD

// view controller for registering new users
class RegisterViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRetypeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        UIUtility.configureTextFields(textFields: [usernameTextField, mailTextField, passwordTextField, passwordRetypeTextField])
    }
    
    @IBAction func registerButtonTapped(_ sender: RoundedButton) {
        SVProgressHUD.show()
        AuthenticationController.registerUser(withName: usernameTextField.text!, email: mailTextField.text!, password: passwordTextField.text!) { (user) in
            if let user = user{
                SVProgressHUD.dismiss()
                NotificationUtility.showPrettyMessage(with: "Du hast dich erfolgreich registriert", button: "ok", style: .success)
                self.dismiss(animated: true, completion: nil)
            }else{
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setTextFieldDelegates(){
        usernameTextField.delegate = self
        mailTextField.delegate = self
        passwordTextField.delegate = self
        passwordRetypeTextField.delegate = self
    }
    
    // hide keyboard when view controller is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension RegisterViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
