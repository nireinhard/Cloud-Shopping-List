//
//  Me.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation

class Me {
    static var uid: String {
        return Auth.auth().currentUser!.uid
    }
}
