//
//  Item.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 17.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation

struct Item{
    var text: String
    var status: Bool
    var by: String
    var userId: String
}

extension Item{
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
