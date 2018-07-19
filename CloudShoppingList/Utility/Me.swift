//
//  Me.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation
import FirebaseAuth

class Me {
    static var uid: String {
        return Auth.auth().currentUser!.uid
    }
    
    static func username(completion: @escaping (String?)->()){
        User.loadUser(userId: Me.uid, completion: { (user) in
            if let user = user{
                completion(user.username)
            }else{
                completion(nil)
            }
        }) {
            completion(nil)
        }
    }
}
