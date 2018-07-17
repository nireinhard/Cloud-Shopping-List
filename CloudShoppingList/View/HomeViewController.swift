//
//  ViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.06.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
import SwiftyJSON

class HomeViewController: UIViewController, FUICollectionDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    let shoppingLists = FUIArray(query: Database.database().reference().child("lists").child(Me.uid).child("joined"))
    var listForSegue: ShoppingList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shoppingLists.observeQuery()
        self.shoppingLists.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = 75
        tableView.tableFooterView = UIView()
        setupData()
    }
    
    private func setupData(){
        var shoppingLists = FirebaseHelper.getRealtimeDB().child("users").child(Me.uid).child("lists").observe(.value) { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            print(postDict)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addSegue", sender: nil)
    }
}

extension HomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(self.shoppingLists.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShoppingListTableViewCell
        let info = JSON((shoppingLists[(UInt(indexPath.row))] as? DataSnapshot)?.value as Any).dictionaryValue
        
        print(info)
        
        print(info["members"])
        
        cell.configure(for: ShoppingList(title: (info["name"]?.stringValue)!), delegate: self)
        
        if let membercount = info["membercount"]?.intValue {
            cell.memberInfoTextField.text = formatMemberInfo(membercount: membercount)
        }else{
            cell.memberInfoTextField.text = "Du"
        }
        
        return cell
    }
    
    func formatMemberInfo(membercount: Int) -> String{
        return "Du und \(membercount - 1) Mitglieder"
    }
    
}

extension HomeViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete){
            // delete from db
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.isUserInteractionEnabled = false
        self.navigationController?.show(DetailsViewController(), sender: nil)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.isUserInteractionEnabled = true
    }
}

extension HomeViewController: ListCellDelegate{
    func buttonTapped(sender: ShoppingListTableViewCell) {
        if let list = sender.shoppingList{
            listForSegue = list
            performSegue(withIdentifier: "detailsSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegue"{
            let destination = segue.destination as? DetailsViewController
            destination?.shoppingList = listForSegue
        }
    }
}

extension HomeViewController{
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
