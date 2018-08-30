//
//  SettingsViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 21.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

struct UserPrivilige{
    let id: String
    let canEdit: Bool
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var listTitleTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var shoppingList: ShoppingList! {
        didSet{
            print("shopping list members")
            print("_________________________________________")
            print(Me.uid)
            print(shoppingList.members)
            print("_________________________________________")
            shoppingList.members.sorted { $0.0.compare($1.0) == .orderedAscending }
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
        let user = membersArray[indexPath.row].id
        let status = membersArray[indexPath.row].canEdit
        
        cell.configure(for: user as! String, with: status as! Bool)
        
        return cell
    }
}

