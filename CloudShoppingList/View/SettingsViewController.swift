//
//  SettingsViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 21.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

struct UserPrivilige{
    var id: String
    var canEdit: Bool
}

// view controller to manage the privilges of the users belonging to the shopping list
class SettingsViewController: UIViewController {

    @IBOutlet weak var listTitleTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shoppingListTitleTextField: UITextField!
    
    var shoppingList: ShoppingList! {
        didSet{
            // transformation of the priviliges Map to an Array of UserPriviliges
            // this is needed for the correct integration with the table view
            shoppingList.priviliges.sorted { $0.0.compare($1.0) == .orderedAscending }
                .forEach { if $0.key != Me.uid{ membersArray.append(UserPrivilige(id: $0.key, canEdit: $0.value)) }}
        }
    }
    
    var membersArray: [UserPrivilige] = [UserPrivilige]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        listTitleTextField.text = shoppingList.title
    }
    
    override func viewDidLayoutSubviews() {
          UIUtility.configureTextFields(textFields: [listTitleTextField], borderColor: UIColor.darkGray.cgColor)
    }
    
    private func setupTable(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func saveButtonTapped(_ sender: RoundedButton) {
        guard let newTitle = shoppingListTitleTextField.text else{
            NotificationUtility.showPrettyMessage(with: "Bitte gib einen Namen für die Liste ein", button: "ok", style: .info)
            return
        }
        
        if var shoppingList = shoppingList {
            shoppingList.changeTitle(newTitle: newTitle)
        }
    }
    
}

extension SettingsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Darf editieren"
        default:
            return "unknown"
        }
    }
}

extension SettingsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return membersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingcell", for: indexPath) as! SettingTableViewCell
        let userId = membersArray[indexPath.row].id
        let status = membersArray[indexPath.row].canEdit
        cell.configure(for: userId as! String, and: shoppingList.listId, with: status as! Bool)
        return cell
    }
}

