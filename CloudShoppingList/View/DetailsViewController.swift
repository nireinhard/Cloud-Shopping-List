//
//  DetailsViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class DetailsViewController: UIViewController {

    @IBOutlet weak var shoppingListNameLabel: UILabel!
    @IBOutlet weak var newItemTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var shoppingList: ShoppingList?
    var items: String = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTable()
    }
    
    override func viewDidLayoutSubviews() {
        UIUtility.configureTextFields(textFields: [newItemTextField], borderColor: UIColor.darkGray.cgColor)
    }
    
    private func setupTable(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
    }
    
    private func setupUI(){
        if let list = shoppingList{
            shoppingListNameLabel.text = list.title
            navigationItem.title = list.title
        }
        // set back button color to white
        UINavigationBar.appearance().tintColor = .white
    }

    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "shareSegue", sender: nil)
    }
    
}

extension DetailsViewController: UITableViewDelegate{
    
}

extension DetailsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        return cell
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

