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
    case invitation, unclassified
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
        }else{
            self.type = .unclassified
        }
        self.message = message
        self.date = date
        self.listId = listId
    }
    
    static func sendInvitationNotification(from receiverUser: User, to senderUser: User, list: ShoppingList){
        let notificationData: [String:Any] = [
            "type": "invitation",
            "message": "\(senderUser.username) möchte dich zu \(list.title) einladen",
            "date": ServerValue.timestamp(),
            "listId": list.listId
        ]
        
        FirebaseHelper.getRealtimeDB().child("users").child(receiverUser.id).child("notifications").childByAutoId().updateChildValues(notificationData)
    }
}
