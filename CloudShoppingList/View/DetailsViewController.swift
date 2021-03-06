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
import ChameleonFramework
import ASHorizontalScrollView
import Presentr
import InitialsImageView

// view controller to present a shopping list
class DetailsViewController: UIViewController, UIScrollViewDelegate {

    private struct ListMember{
        var uid: String
        var username: String
    }
    
    @IBOutlet weak var shoppingListNameLabel: UILabel!
    @IBOutlet weak var newItemTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsLabel: UIImageView!
    @IBOutlet weak var inviteButton: UIBarButtonItem!
    @IBOutlet weak var memberTableView: UITableView!
    
    var ref: UInt?
    var horizontalScrollView: ASHorizontalScrollView?
    var listRepresentation: ListRepresentation?
    var shoppingList: ShoppingList? {
        didSet{
            setupUI()
            if firstLoad {
                loadMembers {
                    self.memberTableView.reloadData()
                    self.setupScrollViewContent()
                    self.firstLoad = false
                }
            }
        }
    }
    
    private var firstLoad = true
    private var members: [User] = []
    
    // retrieves all members of this shopping list and adds them to the members array
    private func loadMembers(completion: @escaping ()->()){
        shoppingList?.members.forEach({ (uid, status) in
            User.loadUser(userId: uid, completion: { (user) in
                if let user = user{
                    self.members.append(user)
                    completion()
                }
            }, fail: {})
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = loadList()
        setupUI()
        setupTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.memberTableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.memberTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let ref = ref{
            FirebaseHelper.detachListener(ref)
        }
    }
    
    override func viewDidLayoutSubviews() {
        UIUtility.configureTextFields(textFields: [newItemTextField], borderColor: UIColor.darkGray.cgColor)
    }
    
    private func loadList() -> UInt?{
        if let list = listRepresentation{
            let ref = ShoppingList.loadShoppingList(mode: .subscribe, listId: list.listId) { [weak self] (list) in
                // shopping list loaded, attach content to table view
                self?.shoppingList = list
                self?.tableView.reloadData()
                self?.memberTableView.reloadData()
                print(self?.shoppingList?.content)
                self?.shoppingListNameLabel.text = list.title
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
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self
    }
    
    private func setupUI(){
        if let list = listRepresentation{
            shoppingListNameLabel.text = list.listName
            navigationItem.title = list.listName
        }
        if let list = shoppingList{
            if list.initiator != Me.uid{
                settingsLabel.isHidden = true
                inviteButton.isEnabled = false
                inviteButton.title = ""
            }
        }
        // set back button color to white
        UINavigationBar.appearance().tintColor = .white
    }

    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "shareSegue", sender: nil)
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "settingsSegue", sender: nil)
    }
    
    // manages different segues for the current view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shareSegue"{
            let destination = segue.destination as? ShareViewController
            if let shoppingList = self.shoppingList{
                destination?.list = shoppingList
            }
        }else if segue.identifier == "settingsSegue"{
            let destination = segue.destination as? SettingsViewController
            if let shoppingList = self.shoppingList{
                destination?.shoppingList = shoppingList
            }
        }
    }
    
    // called when add item button is tapped
    @IBAction func addItemButtonTapped(_ sender: RoundedButton) {
        guard let itemText = newItemTextField.text, !itemText.isEmpty else{
            NotificationUtility.showPrettyMessage(with: "Bitte gib einen Text für den Eintrag ein", button: "ok", style: .error)
            return
        }
       
        if let shoppingList = shoppingList{
            User.loadUser(userId: Me.uid, completion: { [weak self] (user) in
                if let user = user {
                    let item = Item(text: itemText, status: false, by: user.username, userId: Me.uid)
                    var list = shoppingList
                    list.addItem(item: item, userId: Me.uid, success: {
                        Notification.sendAddIitemInfoNotification(from: user, list: shoppingList, item: item)
                        self?.newItemTextField.text = ""
                    })
                }
            }) {
                NotificationUtility.showPrettyMessage(with: "Fehler beim Hinzufügen aufgetreten", button: "ok", style: .error)
            }
        }
        
    }
    
    // used to remove users by tapping on their avatar
    // only initiator can remove other users
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        if let view = gesture.view{
            if let index = horizontalScrollView?.items.index(of: view), var shoppingList = shoppingList{
                let tappedMember = members[index]
                
                let alert = UIAlertController(title: "Person entfernen", message: "Möchtest du \(tappedMember.username) wirklich entfernen?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ja", style: .default, handler: { (action) in
                    if shoppingList.initiator == Me.uid{
                        if tappedMember.id == Me.uid{
                            NotificationUtility.showPrettyMessage(with: "Der Eigentümer kann nicht nicht entfernt werden", button: "ok", style: .error)
                        }else{
                            shoppingList.removeMember(userId: tappedMember.id)
                            self.horizontalScrollView!.refreshSubView() 
                            self.memberTableView.reloadData()
                        }
                    }else{
                        NotificationUtility.showPrettyMessage(with: "Du hast keine Berechtigung Personen zu entfnernen", button: "ok", style: .error)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Nein", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    // hide keyboard when view controller is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension DetailsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.tableView{
            return 55
        }
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == self.tableView{
            if let shoppingList = shoppingList{
                // only allow deleting if current user has write access or is initiator
                return Me.uid == shoppingList.initiator || shoppingList.priviliges[members[indexPath.row].id]!
            }
            return false
        } else if tableView == self.memberTableView{
            return false
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            if var shoppingList = shoppingList{
                shoppingList.removeItem(at: indexPath.row)
                tableView.reloadData()
            }
        }
    }
}

extension DetailsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            if let shoppingList = shoppingList{
                return shoppingList.content.count
            }
        }else if tableView == self.memberTableView {
           return 1
        }
        return 1
    }
    
    // setup the member icons
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if let shoppingList = shoppingList{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
                let item = shoppingList.content[indexPath.row]
                let editStatus = shoppingList.checkPrivilige(Me.uid)
                print("item: \(item)")
                cell.configure(for: item, with: editStatus, delegate: self)
                cell.backgroundColor = item.status ? UIColor.flatLime : UIColor.flatWatermelon
                return cell
            }
        }
        
        if tableView == self.memberTableView{
            let CellIdentifierPortrait = "CellPortrait";
            let CellIdentifierLandscape = "CellLandscape";
            let indentifier = self.view.frame.width > self.view.frame.height ? CellIdentifierLandscape : CellIdentifierPortrait
            var cell = memberTableView.dequeueReusableCell(withIdentifier: indentifier)
            
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: indentifier)
                cell?.selectionStyle = .none
                
                horizontalScrollView = ASHorizontalScrollView(frame:CGRect(x: 0, y: 0, width: memberTableView.frame.size.width, height: 100))
                horizontalScrollView?.defaultMarginSettings = MarginSettings(leftMargin: 10, miniMarginBetweenItems: 0, miniAppearWidthOfLastItem: 20)
                
                horizontalScrollView?.uniformItemSize = CGSize(width: 80, height: 80)
                
                horizontalScrollView?.setItemsMarginOnce()
                
                setupScrollViewContent()
                
                cell?.contentView.addSubview(horizontalScrollView!)
                horizontalScrollView?.translatesAutoresizingMaskIntoConstraints = false
                cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView as Any, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: cell!.contentView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
                cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView as Any, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: cell!.contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
                cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView as Any, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100))
                cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView as Any, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: cell!.contentView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0))
                cell?.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                
            }else if let horizontalScrollView = cell?.contentView.subviews.first(where: { (view) -> Bool in
                return view is ASHorizontalScrollView
            }) as? ASHorizontalScrollView {
                horizontalScrollView.refreshSubView() //refresh view incase orientation changes
            }
            
            return cell!
        }
        
        return UITableViewCell()
    }
    
    func setupScrollViewContent(){
        let _ = horizontalScrollView?.removeAllItems()
        self.members.forEach { (user) in
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))) )
            imageView.setImageForName(string: user.username, backgroundColor: nil, circular: true, textAttributes: nil)
            self.horizontalScrollView?.addItem(imageView)
        }
    }
}

extension DetailsViewController: ItemCellDelegate{
    func buttonTapped(sender: ItemTableViewCell, check: Bool, itemId: String) {
        if var shoppingList = shoppingList{
            if (check) {
                shoppingList.checkItem(itemId)
            }else {
                shoppingList.uncheckItem(itemId)
            }
        }
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

