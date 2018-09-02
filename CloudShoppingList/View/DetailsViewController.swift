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

class DetailsViewController: UIViewController {

    @IBOutlet weak var shoppingListNameLabel: UILabel!
    @IBOutlet weak var newItemTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsLabel: UIImageView!
    @IBOutlet weak var inviteButton: UIBarButtonItem!
    @IBOutlet weak var memberTableView: UITableView!
    
    var horizontalScrollView: ASHorizontalScrollView?
    var listRepresentation: ListRepresentation?
    var shoppingList: ShoppingList? {
        didSet{
            setupUI()
        }
    }
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
    
    @IBAction func addItemButtonTapped(_ sender: RoundedButton) {
        guard let itemText = newItemTextField.text, !itemText.isEmpty else{
            NotificationUtility.showPrettyMessage(with: "Bitte gib einen Text für den Eintrag ein", button: "ok", style: .error)
            return
        }
       
        if var shoppingList = shoppingList{
            Me.username { (username) in
                if let username = username{
                    let item = Item(text: itemText, status: false, by: username, userId: Me.uid)
                    shoppingList.addItem(item: item, userId: Me.uid)
                    self.newItemTextField.text = ""
                }
            }
        }
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        if let view = gesture.view{
            if let index = horizontalScrollView?.items.index(of: view){
            }
        }
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
                return Me.uid == shoppingList.initiator
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
            if let shoppingList = shoppingList{
                return shoppingList.members.count
            }
        }
       
        return 0
    }
    
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
        if let members = shoppingList?.members{
            let membersActive = members.filter { (key: String, value: Bool) -> Bool in
                return value
                }
            print("membersactive \(membersActive)")
            membersActive.forEach { (key: String, value: Bool) in
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))) )
                    imageView.setImageForName(string: key, backgroundColor: nil, circular: true, textAttributes: nil)
                    horizontalScrollView?.addItem(imageView)
            }
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

