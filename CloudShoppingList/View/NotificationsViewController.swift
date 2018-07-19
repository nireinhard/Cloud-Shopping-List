//
//  NotificationsViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 19.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }
    
    private func setupTable(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
    }
}

extension NotificationsViewController: UITableViewDelegate{
    
}

extension NotificationsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension NotificationsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "emptynotifications")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSAttributedString(string: "Keine Benachrichtigungen")
        return title
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let font = UIFont.systemFont(ofSize: 12)
        let attrsDictionary = [NSAttributedStringKey.font: font]
        let description = NSAttributedString(string: "", attributes: attrsDictionary)
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
