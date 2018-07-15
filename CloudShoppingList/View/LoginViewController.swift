//
//  LoginViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 14.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController {
    
    private enum ViewControllerType{
        case home, login
    }

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLayoutSubviews() {
         UIUtility.configureTextFields(textFields: [mailTextField, passwordTextField])
        setTextFieldDelegates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonTapped(_ sender: RoundedButton) {
        loginUser(email: mailTextField.text!, password: passwordTextField.text!)
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        self.pushTo(viewController: .login)
    }
    
    private func pushTo(viewController: ViewControllerType){
        switch viewController {
        case .home:
            performSegue(withIdentifier: "loginSegue", sender: nil)
        case .login:
            performSegue(withIdentifier: "registerSegue", sender: nil)
        }
    }
    
    private func loginUser(email: String, password: String){
        SVProgressHUD.show(withStatus: "Anmelden..")
        AuthenticationController.loginUser(withEmail: email, password: password) { (userId) in
            if let userId = userId{
                SVProgressHUD.dismiss()
                self.pushTo(viewController: .home)
            }else{
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func setTextFieldDelegates(){
        mailTextField.delegate = self
        passwordTextField.delegate = self
    }
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
