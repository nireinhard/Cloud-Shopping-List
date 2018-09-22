//
//  Item.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 17.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation

// struct to represent a shopping list item
struct Item{
    var itemId: String
    var text: String
    var status: Bool
    var by: String
    var userId: String
    
    init(text: String, status: Bool, by: String, userId: String){
        self.itemId = "-1"
        self.text = text
        self.status = status
        self.by = by
        self.userId = userId
    }
    
    init(itemId: String, text: String, status: Bool, by: String, userId: String){
        self.init(text: text, status: status, by: by, userId: userId)
        self.itemId = itemId
    }
    
}

extension Item{
    // returns the dictionary representation of the current item
    func toDictionary()-> [String:Any]{
        let itemDict: [String:Any] = [
            "by": self.by,
            "userId": self.userId,
            "status": self.status,
            "text": self.text
        ]
        return itemDict
    }
}
