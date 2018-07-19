//
//  ShareViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {

    @IBOutlet weak var shareLinkLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var allUsers: [User] = []
    var result: [User] = []
    var list: ShoppingList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateShareLink()
        setupTable()
        loadAllUsers()
        UIUtility.configureTextFields(textFields: [usernameTextField])
    }
    
    private func loadAllUsers(){
        User.loadAllUsers(completion: { (userlist) in
            self.setAllUsers(result: userlist)
        }) {
            NotificationUtility.showPrettyMessage(with: "Benutzer konnten nicht geladen werden", button: "ok", style: .error)
        }
    }
    
    private func generateShareLink(){
        var base = "fbase.io/98543i"
        shareLinkLabel.text = base
    }
    
    private func setupTable(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    private func setAllUsers(result: [User]){
        allUsers = result
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
        //if let list = list{
            cell.configure(for: user, list: list!, delegate: self)
        //}
        return cell
    }
}

extension ShareViewController: InviteCellDelegate{
    func buttonTapped(sender: InviteTableViewCell) {
        if let senderUser = sender.user{
            inviteUser(senderUser)
        }
    }
    
    func inviteUser(_ senderUser: User){
        User.loadUser(userId: Me.uid, completion: { (user) in
            if let receiverUser = user, let list = self.list{
                Notification.sendInvitationNotification(from: senderUser, to: receiverUser, list: list)
                NotificationUtility.showPrettyMessage(with: "Deine Einladung wurde versendet", button: "ok", style: .success)
                self.refreshView()
            }
        }) {}
    }
}
