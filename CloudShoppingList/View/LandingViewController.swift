//
//  LandingViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

enum ViewControllerType {
    case home
    case login
}

class LandingViewController: UIViewController {
    
    //MARK: Push to relevant ViewController
    private func pushTo(viewController: ViewControllerType)  {
        switch viewController {
        case .home:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController") as! TabViewController
            self.present(vc, animated: false, completion: nil)
        case .login:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    //MARK: Check if user is signed in or not
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let userInformation = UserDefaults.standard.dictionary(forKey: "userInformation") {
            let savedUserId = userInformation["userid"] as! String
            let savedEmail = userInformation["email"] as! String
            let savedPassword = userInformation["password"] as! String
            AuthenticationController.loginUser(withEmail: savedEmail, password: savedPassword) { [weak weakSelf = self](userId) in
                DispatchQueue.main.async {
                    if let userId = userId, userId == savedUserId {
                        weakSelf?.pushTo(viewController: .home)
                    } else {
                        weakSelf?.pushTo(viewController: .login)
                    }
                    weakSelf = nil
                }
            }
        } else {
            self.pushTo(viewController: .login)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
}
