//
//  LoginViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 14.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import SVProgressHUD
import GoogleSignIn

// view controller to login users
class LoginViewController: UIViewController, GIDSignInUIDelegate {

    private enum ViewControllerType{
        case home, login
    }

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // workaround to properly layout textfields
    override func viewDidLayoutSubviews() {
         UIUtility.configureTextFields(textFields: [mailTextField, passwordTextField])
        setTextFieldDelegates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup google button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: view.frame.height - 100, width: view.frame.width-32, height: 50)
        view.addSubview(googleButton)
        GIDSignIn.sharedInstance().uiDelegate = self
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
    
    // hide keyboard when view controller is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
