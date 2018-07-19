//
//  DetailsViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import FirebaseDatabase
import FirebaseUI
import SwiftyJSON

class DetailsViewController: UIViewController {

    @IBOutlet weak var shoppingListNameLabel: UILabel!
    @IBOutlet weak var newItemTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var listRepresentation: ListRepresentation?
    var shoppingList: ShoppingList?
    var ref: UInt?
    
    deinit {
        print("deinitalized details view controller")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = loadList()
        setupUI()
        setupTable()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let ref = ref{
            print("about to detach listener")
            FirebaseHelper.detachListener(ref)
        }
    }
    
    override func viewDidLayoutSubviews() {
        UIUtility.configureTextFields(textFields: [newItemTextField], borderColor: UIColor.darkGray.cgColor)
    }
    
    private func loadList() -> UInt?{
        if let list = listRepresentation{
            // shoppingList = ShoppingList(listId: list.listId)
            let ref = ShoppingList.loadShoppingList(mode: .subscribe, listId: list.listId) { [unowned self] (list) in
                // shopping list loaded, attach content to table view
                self.shoppingList = list
                self.tableView.reloadData()
                print(self.shoppingList?.content)
                self.shoppingListNameLabel.text = list.title
            }
            return ref
        }
        return nil
    }
    
    private func setupTable(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 55
    }
    
    private func setupUI(){
        if let list = listRepresentation{
            shoppingListNameLabel.text = list.listName
            navigationItem.title = list.listName
        }
        // set back button color to white
        UINavigationBar.appearance().tintColor = .white
    }

    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "shareSegue", sender: nil)
    }
    
    @IBAction func addItemButtonTapped(_ sender: RoundedButton) {
        guard let itemText = newItemTextField.text, !itemText.isEmpty else{
            NotificationUtility.showPrettyMessage(with: "Bitte gib einen Text für den Eintrag ein", button: "ok", style: .error)
            return
        }
       
        if var shoppingList = shoppingList{
            Me.username { (username) in
                if let username = username{
                    let item = Item(text: itemText, status: false, by: username, userId: Me.uid)
                    shoppingList.addItem(item: item)
                    self.newItemTextField.text = ""
                }
            }
        }
        
    }
    
}

extension DetailsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let shoppingList = shoppingList{
            return Me.uid == shoppingList.initiator
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            if var shoppingList = shoppingList{
                shoppingList.content.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
    }
}

extension DetailsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let shoppingList = shoppingList{
            return shoppingList.content.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let shoppingList = shoppingList{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
            let item = shoppingList.content[indexPath.row]
            cell.configure(for: item, delegate: self)
            return cell
        }
        return UITableViewCell()
    }
}

extension DetailsViewController: ItemCellDelegate{
    func buttonTapped(sender: ItemTableViewCell) {
        
    }
}

extension DetailsViewController{
    func array(_ array: FUICollection, didAdd object: Any, at index: UInt) {
        self.tableView.insertRows(at: [IndexPath(row: Int(index), section: 0)], with: .automatic)
    }
    
    func array(_ array: FUICollection, didMove object: Any, from fromIndex: UInt, to toIndex: UInt) {
        self.tableView.insertRows(at: [IndexPath(row: Int(toIndex), section: 0)], with: .automatic)
        self.tableView.deleteRows(at: [IndexPath(row: Int(fromIndex), section: 0)], with: .automatic)
        
        
    }
    func array(_ array: FUICollection, didRemove object: Any, at index: UInt) {
        self.tableView.deleteRows(at: [IndexPath(row: Int(index), section: 0)], with: .automatic)
        
        
    }
    func array(_ array: FUICollection, didChange object: Any, at index: UInt) {
        self.tableView.reloadRows (at: [IndexPath(row: Int(index), section: 0)], with: .none)
    }
}


extension DetailsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "emptyList")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSAttributedString(string: "Keine Einträge")
        return title
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let font = UIFont.systemFont(ofSize: 12)
        let attrsDictionary = [NSAttributedStringKey.font: font]
        let description = NSAttributedString(string: "Füge einen Eintrag hinzu", attributes: attrsDictionary)
        return description
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        if let navigationBar = navigationController?.navigationBar {
            return -navigationBar.frame.height * 0.75
        }
        return 0
    }
    
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView!) {
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
}

