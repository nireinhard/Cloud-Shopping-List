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
    let shoppingLists = FUISortedArray(query: Database.database().reference().child("Users").child(Me.uid).child("Contacts"), delegate: nil) { (lhs, rhs) -> ComparisonResult in
        let lhs = Date(timeIntervalSinceReferenceDate: JSON(lhs.value as Any)["lastMessage"]["date"].doubleValue)
        let rhs = Date(timeIntervalSinceReferenceDate:JSON(rhs.value as Any)["lastMessage"]["date"].doubleValue)
        return rhs.compare(lhs)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension HomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShoppingListTableViewCell
        let info = JSON((Contacts[(UInt(indexPath.row))] as? DataSnapshot)?.value as Any).dictionaryValue
        cell.Name.text = info["name"]?.stringValue
        cell.lastMessage.text = info["lastMessage"]?["text"].strings
        cell.lastMessageDate.text = dateFormatter(timestamp: info["lastMessage"]?["date"].double)
        return cell
    }
    
    
}

extension HomeViewController: UITableViewDelegate{
    
}
