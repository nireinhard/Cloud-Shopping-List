//
//  ProfileViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import InitialsImageView

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserProfile(Me.uid)
    }

    private func loadUserProfile(_ uid: String){
        User.loadUser(userId: uid, completion: { [weak self](user) in
            // set profile image and username label
            if let user = user {
                self?.profileImageView.setImageForName(string: user.username, backgroundColor: nil, circular: true, textAttributes: nil)
                self?.usernameLabel.text = "\(user.username) \(Me.uid)"
            }
        }) {
            NotificationUtility.showPrettyMessage(with: "Benutzerprofil konnte nicht geladen werden", button: "ok", style: .error)
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        AuthenticationController.logOutUser { (success) in
            if success{
                NotificationListenerController.shared.stopListening()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
