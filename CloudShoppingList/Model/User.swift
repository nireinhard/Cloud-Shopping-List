//
//  User.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 14.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import FirebaseFirestore

enum UpdateStatus{
    case initialWrite, update
}

struct ListRepresentation{
    let listId: String
    let listName: String
}

class User{
    var id: String
    var username: String
    var mail: String
    var mode: String?
    var lists: [ListRepresentation]?
    
    init(id: String, username: String, mail: String){
        self.id = id
        self.username = username
        self.mail = mail
        self.lists = []
    }
    
    init(userId: String, data: Dictionary<String, Any>){
        self.id = userId
        self.username = data["username"] as! String
        self.mail = data["mail"] as! String
        self.lists = []
    }
    
    static func retrieveUser(userId: String, completion: @escaping (User?)->()){
        
    }
    
    static func retrieveUserListener(userId: String, completion: @escaping (User?) -> ()) -> ListenerRegistration?{
        return nil
    }
    
    func update(completion: @escaping ()->()){
        let userRef = FirebaseHelper.getRealtimeDB().child("users").child(Me.uid);
        let jsonUser = toJson(mode: .update)
        
        userRef.setValue(jsonUser) { (error, ref) in
            if let error = error{
                print("Error updating user document: \(error)")
            }else{
                print("User document successfully updated")
                completion()
            }
        }
    }
    
    func save(completion: @escaping ()->()){
        let userRef = FirebaseHelper.getRealtimeDB().child("users").child(Me.uid);
        let jsonUser = toJson(mode: .initialWrite)
        
        userRef.setValue(jsonUser) { (error, ref) in
            if let error = error{
                print("Error updating user document: \(error)")
            }else{
                print("User document successfully updated")
                completion()
            }
        }
    }
}

extension User{
    
    private func getMetadataJson(_ mode: UpdateStatus) -> [String:Any]{
        var metadataJson: [String : Any] = [
            "mail": self.mail,
            "username": self.username,
            "updated": ServerValue.timestamp()
        ]
        
        if mode == .initialWrite{
            metadataJson["created"] = ServerValue.timestamp()
        }
        return metadataJson
    }
    
    private func getListJson() -> [String:Any]{
        var listJson: [String:Any] = [:]
        
        let mockList = ListRepresentation(listId: "45353452", listName: "Neuer Code Test")
        let mockList2 = ListRepresentation(listId: "3267634", listName: "Wochenendeinkauf")
        let mockLists = [mockList, mockList2]

        for list in mockLists{
            listJson[list.listId] = ["listId": list.listId, "title": list.listName]
        }
        
        return listJson
    }
    
    private func getNotificationJson() -> [String:Any]{
        let notifactionJson: [String:Any] = [:]
        return notifactionJson
    }
    
    func toJson(mode: UpdateStatus) -> [String:Any]{
        let metadataJson = getMetadataJson(mode)
        let listJson = getListJson()
        
        let userJson: [String : Any] = [
            "lists": listJson,
            "metadata": metadataJson,
            "notifications": getNotificationJson()
        ]
        
        return userJson
    }
}

extension User:Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

