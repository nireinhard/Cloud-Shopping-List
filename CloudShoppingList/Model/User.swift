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
import SwiftyJSON

enum UpdateStatus{
    case initialWrite, update
}

// representation of a list to store in the user object
struct ListRepresentation{
    let listId: String
    let listName: String
}

// struct representing a user object
struct User{
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
    
    init(id: String, username: String, mail: String, lists: [ListRepresentation]){
        self.init(id: id, username: username, mail: mail)
        self.lists = lists
    }
    
    // creates a user object from a givin userid and JSON data and returns it, if successful
    private static func createUserFromJSON(userId: String, data: JSON) -> User?{
        let data = data.dictionaryValue
        let metadata = data["metadata"]?.dictionaryValue
        let listdata = data["lists"]?.dictionaryValue
       
        guard let meta = metadata else {
            return nil
        }

        let username = meta["username"]?.stringValue
        let mail = meta["mail"]?.stringValue
        
        var lists: [ListRepresentation] = []
        
        if let listdata = listdata{
            for listitem in listdata{
                let listitemDictionary = listitem.value.dictionaryValue
                let listId = listitemDictionary["listId"]?.stringValue
                let title = listitemDictionary["title"]?.stringValue
                if let listId = listId, let title = title{
                    let listRepresentation = ListRepresentation(listId: listId, listName: title)
                    lists.append(listRepresentation)
                }
            }
        }
        
        let user: User = User(id: userId, username: username!, mail: mail!, lists: lists)
        
        return user
    }
    
    // retrieves all users in the database
    static func loadAllUsers(completion: @escaping ([User])->(), fail: @escaping ()->()){
         FirebaseHelper.getRealtimeDB().child("users").observeSingleEvent(of: .value) { (snapshot) in
            let allUserData = JSON(snapshot.value).dictionaryValue
            
            var userList: [User] = []
            
            for elem in allUserData{
                let userId = elem.key
                let data = elem.value
                let user = createUserFromJSON(userId: userId, data: data)
                if let user = user{
                    //exclude current user
                    if userId != Me.uid{
                        userList.append(user)
                    }
                }
            }
            
            completion(userList)
        }
    }
    
    // retrieves a single user from the database, identified by the userid
    static func loadUser(userId: String, completion: @escaping (User?)->(), fail: @escaping ()->()){
        let userRef = FirebaseHelper.getRealtimeDB().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            let data = JSON(snapshot.value)
            let user = createUserFromJSON(userId: userId, data: data)
            if let user = user{
                completion(user)
            }else{
                fail()
            }
        }
    }
    
    // used when a user registers with either google or facebook to complete the user information
    // which is needed for the app to work properly
    static func addMissingInfo(for userId: String, with username: String, completion: @escaping (Bool)->()){
        let newValues = [
            "username": username,
            "mail": ""]
        FirebaseHelper.getRealtimeDB().child("users").child(Me.uid).child("metadata").updateChildValues((newValues)) { (err, user) in
            if let err = err {
                completion(false)
            }else{
                completion(true)
            }
            }
    }
    
    // used to save the current user object to the database
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
    
    // responsible to transform the user metadata to a json document based on the update status
    // update status = .initialWrite => include created field
    private func getMetadataJson(_ mode: UpdateStatus) -> [String:Any]{
        // ServerValue.timestamp might be shown as an error in xcode but the project compiles nevertheless
        // and everything works properly
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

