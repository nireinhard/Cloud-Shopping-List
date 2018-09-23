//
//  ShareViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

// view controller to invite users to a shopping list
class ShareViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var allUsers: [User] = []
    var result: [User] = []
    var list: ShoppingList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        loadAllUsers()
    }
    
    // workaround to properly layout textfields
    override func viewDidLayoutSubviews() {
        UIUtility.configureTextFields(textFields: [usernameTextField], borderColor: UIColor.darkGray.cgColor)
    }
    
    // retrieves all users from the database and saves them in the user array
    private func loadAllUsers(){
        User.loadAllUsers(completion: { [weak self](userlist) in
            print("all users \(userlist)")
            self?.allUsers = userlist
        }) {
            NotificationUtility.showPrettyMessage(with: "Benutzer konnten nicht geladen werden", button: "ok", style: .error)
        }
    }
    
    private func setupTable(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func searchButtonTapped(_ sender: RoundedButton) {
        if let usernameQuery = usernameTextField.text{
            result = allUsers.filter { (user) -> Bool in
                return user.username == usernameQuery
            }
            if result.isEmpty{
                NotificationUtility.showPrettyMessage(with: "Kein Benutzer \(usernameQuery) gefunden", button: "ok", style: .error)
            }
            tableView.reloadData()
        }
    }
    
    private func refreshView(){
        loadAllUsers()
        result = allUsers.filter { (user) -> Bool in
            return user.username == usernameTextField.text!
        }
        self.tableView.reloadData()
    }
    
    // hide keyboard when view controller is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ShareViewController: UITableViewDelegate{
    
}

extension ShareViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InviteTableViewCell
        let user = result[indexPath.row]
        cell.configure(for: user, list: list!, delegate: self)
        return cell
    }
}

extension ShareViewController: InviteCellDelegate{
    func buttonTapped(sender: InviteTableViewCell) {
        if let receiverUser = sender.user{
            inviteUser(receiverUser)
        }
    }
    
    func inviteUser(_ receiverUser: User){
        User.loadUser(userId: Me.uid, completion: { (user) in
            if let senderUser = user{
                Notification.sendInvitationNotification(from: senderUser, to: receiverUser, list: self.list!)
                self.list!.addMember(userId: receiverUser.id)
                NotificationUtility.showPrettyMessage(with: "Deine Einladung wurde versendet", button: "ok", style: .success)
                self.refreshView()
            }
        }) {}
    }
}
