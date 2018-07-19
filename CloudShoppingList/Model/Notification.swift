//
//  Notification.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 19.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation

enum NotificationType{
    case invitation
}

struct Notification{
    var notificationId: String
    var type: NotificationType
    var message: String
    var date: TimeInterval
    var listId: String
}
