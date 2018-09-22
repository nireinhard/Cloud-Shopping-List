//
//  ProfileViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import InitialsImageView

// view controller to show current profile information
// currently this is only the username and the generated image for the username
class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        loadUserProfile(Me.uid)
        print(Me.uid)
    }

    // loads the user profile specified by the userId
    private func loadUserProfile(_ userId: String){
        User.loadUser(userId: userId, completion: { [weak self](user) in
            // set profile image and username label
            if let user = user {
                self?.profileImageView.setImageForName(string: user.username, backgroundColor: nil, circular: true, textAttributes: nil)
                self?.usernameLabel.text = "\(user.username)"
            }
        }) {
            NotificationUtility.showPrettyMessage(with: "Benutzerprofil konnte nicht geladen werden", button: "ok", style: .error)
        }
    }
    
    // triggered when logout button is tapped
    // logs the current user out and stops listening for notifications
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        AuthenticationController.logOutUser { (success) in
            if success{
                NotificationListenerController.shared.stopListening()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
