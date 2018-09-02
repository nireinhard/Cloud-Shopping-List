//
//  NotificationListenerController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 19.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation
import SwiftyJSON
import FirebaseDatabase

protocol NotificationListener: AnyObject{
    func update()
}

class NotificationListenerController{
    
    static let shared = NotificationListenerController()
    var listener: NotificationListener?
    var notifications: [Notification] = [] {
        didSet{
            listener?.update()
        }
    }
    var ref: DatabaseHandle?
    var listening = false
    
    private init(){
    }
    
    func removeNotification(notification: Notification){
        let index = notifications.index { (localnotification) -> Bool in
            notification.notificationId == localnotification.notificationId
        }
        if let index = index {
            notifications.remove(at: index)
            FirebaseHelper.getRealtimeDB().child("users").child(Me.uid).child("notifications").child(notification.notificationId).setValue(nil)
            listener?.update()
        }
    }
    
    func startListening(completion: @escaping()->()){
        if listening{
            return
        }
        
        print("started listening for notifications")
        ref = FirebaseHelper.getRealtimeDB().child("users").child(Me.uid).child("notifications").observe(.value) { (snapshot) in
            self.listening = true
            self.notifications.removeAll()
            let data = JSON(snapshot.value).dictionaryValue
            
            for entry in data{
                let notificationId = entry.key
                let notificationData = entry.value.dictionaryValue
                let type = notificationData["type"]?.stringValue
                let message = notificationData["message"]?.stringValue
                let date = notificationData["date"]?.doubleValue
                let listId = notificationData["listId"]?.stringValue
                if let type = type, let message = message, let date = date, let listId = listId{
                    let notification = Notification.init(notificationId: notificationId, type: type, message: message, date: date, listId: listId)
                    self.notifications.append(notification)
                    completion()
                }
            }
            
            print(self.notifications)
        }
    }
    
    func stopListening(){
        if let ref = ref{
            FirebaseHelper.detachListener(ref)
            listening = false
        }
    }
}
