//
//  ShoppingList.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ShoppingList{
    var listId: String
    var title: String
    var members: [User]
    var initiator: User?
    var createdAt: ServerValue?
    
    init(title: String){
        self.title = title
        self.listId = ""
        self.members = []
    }
    
}
