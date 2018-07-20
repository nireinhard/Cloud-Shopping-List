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
        NotificationListenerController.shared.listener = self
    }
    
    private func setupTable(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 75
    }
}

extension NotificationsViewController: NotificationListener{
    func update() {
        tableView.reloadData()
        if NotificationListenerController.shared.notifications.count != 0{
            self.navigationController?.tabBarItem.badgeValue = "\(NotificationListenerController.shared.notifications.count)"
        }
    }
}

extension NotificationsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension NotificationsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationListenerController.shared.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationcell", for: indexPath) as! NotificationInvitationTableViewCell
        let invitation = NotificationListenerController.shared.notifications[indexPath.row]
        
        cell.configure(notification: invitation, delegate: self)

        return cell
    }
}

extension NotificationsViewController: InvitationActionDelegate{
    func acceptedTapped(notification: Notification) {
        print("accepted tapped")
        // in 'lists' set user to true
        FirebaseHelper.getRealtimeDB().child("lists").child(notification.listId).child("members").child(Me.uid).setValue(true)
        
        ShoppingList.loadShoppingList(listId: notification.listId) { (list) in
            let newListRepresentationJson: [String:Any] = [
                "title": list.title,
                "listId": list.listId
            ]
            FirebaseHelper.getRealtimeDB().child("users").child(Me.uid).child("lists").child(list.listId).setValue(newListRepresentationJson)
        }
        // remove notification
        NotificationListenerController.shared.removeNotification(notification: notification)
    }
    
    func declinedTapped(notification: Notification) {
        // remove user from 'lists' member
        FirebaseHelper.getRealtimeDB().child("lists").child(notification.listId).child("members").child(Me.uid).setValue(nil)
        // remove notification
         NotificationListenerController.shared.removeNotification(notification: notification)
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
