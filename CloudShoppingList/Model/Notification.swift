//
//  Notification.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 19.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation
import FirebaseDatabase

enum NotificationType{
    case invitation, info, unclassified
}

struct Notification{
    var notificationId: String
    var type: NotificationType
    var message: String
    var date: TimeInterval
    var listId: String
    
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
        let notificationData: [String:Any] = [
            "type": "info",
            "message": "\(senderUser.username) hat \(item.text) zu \(list.title) hinzugefügt",
            "date": ServerValue.timestamp(),
            "listId": list.listId
        ]
        
        for member in list.members{
            if member.value{
                if member.key != Me.uid{
                 FirebaseHelper.getRealtimeDB().child("users").child(member.key).child("notifications").childByAutoId().updateChildValues(notificationData)
                }
            }
        }
    }
    
    static func sendInvitationNotification(from senderUser: User, to receiverUser: User, list: ShoppingList){
        let notificationData: [String:Any] = [
            "type": "invitation",
            "message": "\(senderUser.username) möchte dich zu \(list.title) einladen",
            "date": ServerValue.timestamp(),
            "listId": list.listId
        ]
        FirebaseHelper.getRealtimeDB().child("users").child(receiverUser.id).child("notifications").childByAutoId().updateChildValues(notificationData)
    }
    
    static func getAllNotifcationsFor(userId: String){
        FirebaseHelper.getRealtimeDB().child("users").child(userId).child("notifications").observeSingleEvent(of: .value) { (snapshot) in
                
        }
    }
}
