//
//  Notification.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 19.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Alamofire

enum NotificationType{
    case invitation, info, unclassified
}

// struct to represent a notification
struct Notification{
    var notificationId: String
    var type: NotificationType
    var message: String
    var date: TimeInterval
    var listId: String
    
    // initializes a notification
    init(notificationId: String, type: String, message: String, date: Double, listId: String){
        self.notificationId = notificationId
        if type == "invitation"{
            self.type = .invitation
        }else if type == "info"{
            self.type = .info
        }else{
            self.type = .unclassified
        }
        self.message = message
        self.date = date
        self.listId = listId
    }
    
    static func sendAddIitemInfoNotification(from senderUser: User, list: ShoppingList, item: Item){
        let message = "\(senderUser.username) hat \(item.text) zu \(list.title) hinzugefügt"
        let notificationData: [String:Any] = [
            "type": "info",
            "message": message,
            "date": ServerValue.timestamp(),
            "listId": list.listId
        ]
        
        for member in list.members{
            if member.value{
                if member.key != Me.uid{
                    // adds the notification to the user in the users collection
                    FirebaseHelper.getRealtimeDB().child("users").child(member.key).child("notifications").childByAutoId().updateChildValues(notificationData)
                    // push the notification tot the user
                    sendPushNotification(title: "Neue Position", message, member.key)
                }
            }
        }
    }
    
    static func sendInvitationNotification(from senderUser: User, to receiverUser: User, list: ShoppingList){
        let message = "\(senderUser.username) möchte dich zu \(list.title) einladen"
        let notificationData: [String:Any] = [
            "type": "invitation",
            "message": message,
            "date": ServerValue.timestamp(),
            "listId": list.listId
        ]
        // adds the notification to the user in the users collection
        FirebaseHelper.getRealtimeDB().child("users").child(receiverUser.id).child("notifications").childByAutoId().updateChildValues(notificationData)
        // push the notification tot the user
        sendPushNotification(title: "Neue Einladung", message, receiverUser.id)
    }
    
    static func getAllNotifcationsFor(userId: String){
        FirebaseHelper.getRealtimeDB().child("users").child(userId).child("notifications").observeSingleEvent(of: .value) { (snapshot) in
                
        }
    }
    
    // responsible to send a push notification to a specified user through the API
    private static func sendPushNotification(title: String, _ message: String, _ userId: String){
        let parameters: Parameters = [
            "secret": "1234ABCD",
            "topic": userId,
            "body": message,
            "title": title
        ]
        Alamofire.request("https://shoppinglist-service.herokuapp.com/messages", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:])
    }
}
