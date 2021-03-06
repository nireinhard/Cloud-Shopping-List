//
//  FirebaseHelper.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 14.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseDatabase

// firebase helper methods for configured firebase access
struct FirebaseHelper{
    private static var db: Firestore? = nil
    private static let ref: DatabaseReference! = Database.database().reference()
    
    static func getRealtimeDB() -> DatabaseReference{
        return self.ref
    }
    
    static func getDb() -> Firestore{
        if let db = self.db{
            return db
        }else{
            self.db = Firestore.firestore()
            // force unwrap is safe because instance is set prior
            let settings = self.db!.settings
            //settings.isPersistenceEnabled = true
            settings.areTimestampsInSnapshotsEnabled = true
            self.db!.settings = settings
            return self.db!
        }
    }
    
    static func detachListener(_ listener: DatabaseHandle){
        print("unsubscribed from \(listener)")
        ref.removeObserver(withHandle: listener)
    }
}
