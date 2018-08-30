//
//  ShoppingList.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

struct ShoppingList{
    var listId: String
    var title: String
    var members: [String: Bool]
    var initiator: String
    var createdAt: TimeInterval?
    var content: [Item] = []
    var priviliges: [String: Bool]
    
    init(listId: String, title: String, members: [String:Bool], initiator: String, createdAt: TimeInterval?, content: [Item], priviliges: [String:Bool]){
        self.listId = listId
        self.title = title
        self.members = members
        self.initiator = initiator
        self.createdAt = createdAt
        self.content = content
        self.priviliges = priviliges
    }
    
    mutating func addItem(item: Item, userId: String){
        if (checkPrivilige(userId)){
            content.append(item)
            persistItem(item)
        }else{
            NotificationUtility.showPrettyMessage(with: "Du hast keine Berechtigungen Positionen hinzuzufügen", button: "ok", style: .error)
        }
    }
    
    mutating func addMember(userId: String){
        members[userId] = false
        priviliges[userId] = false
        persistMember(userId: userId)
    }
    
    mutating func changeTitle(newTitle: String){
        self.title = newTitle
        persistTitle()
    }
    
    private func persistTitle(){
            FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("title").setValue(self.title)
    }
    
    private func persistItem(_ item: Item){
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("content").childByAutoId().updateChildValues(item.toDictionary())
    }
    
    private func persistMember(userId: String){
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("members").updateChildValues([userId: false])
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("priviliges").updateChildValues([userId: false])
    }
    
    public func checkPrivilige(_ userId: String) -> Bool{
        return priviliges[userId] == true
    }
    
    static func changePrivilige(for userId: String, on shoppingListId: String, newStatus: Bool){
        FirebaseHelper.getRealtimeDB().child("lists").child(shoppingListId).child("priviliges").updateChildValues([userId: newStatus])
    }
    
    static func createShoppingList(title: String, completion: @escaping ()->()){
        let newListJson: [String:Any] = [
            "content": [:],
            "title": title,
            "initiator": Me.uid,
            "members": [Me.uid: true],
            "priviliges": [Me.uid: true],
            "created": ServerValue.timestamp()
        ]
    FirebaseHelper.getRealtimeDB().child("lists").childByAutoId().setValue(newListJson) { (error, ref) in
            if let error = error {
                print(error)
            }else{
                let newListRepresentationJson: [String:Any] = [
                    "title": title,
                    "listId": ref.key
                ]
                FirebaseHelper.getRealtimeDB().child("users").child(Me.uid).child("lists").child(ref.key).setValue(newListRepresentationJson, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        print(error)
                    }else{
                        completion()
                    }
                })
            }
        }
    }
    
    static func deleteShoppingList(listId: String, completion: @escaping ()->(), fail: @escaping ()->()){
        let list = ShoppingList.loadShoppingList(mode: .load, listId: listId) { (list) in
            if Me.uid == list.initiator{
                // user is initiator -> delete list completely
                // delete list in 'users' reference from every member
                for member in list.members{
                    //print("key: \(member.key)")
                    FirebaseHelper.getRealtimeDB().child("users").child(member.key).child("lists").child(listId).setValue(nil)
                }
                // delete list itself
                FirebaseHelper.getRealtimeDB().child("lists").child(list.listId).setValue(nil)
            }else{
                // simply remove user from list and list from user
                FirebaseHelper.getRealtimeDB().child("users").child(Me.uid).child("lists").child(list.listId).setValue(nil)
                FirebaseHelper.getRealtimeDB().child("lists").child(list.listId).child("members").child(Me.uid).setValue(nil)
                FirebaseHelper.getRealtimeDB().child("lists").child(list.listId).child("priviliges").child(Me.uid).setValue(nil)
                completion()
            }
        }
    }
 
    private static func createShoppingListFromJSON(listId: String, data: JSON) -> ShoppingList?{
        let data = data.dictionaryValue
        
        var memberDictionary: [String:Bool] = [:]
        
        print("data: \(data)")
        let initiator = data["initiator"]?.stringValue
        let title = data["title"]?.stringValue
        let content = data["content"]?.dictionaryValue
        print("datacontent: \(content)")
        
        let members = data["members"]?.dictionaryValue
        
        if let members = members{
            for member in members{
                memberDictionary[member.key] = member.value.boolValue
            }
        }
        
        var priviligeDictionary: [String:Bool] = [:]
        let priviliges = data["priviliges"]?.dictionaryValue
        
        if let priviliges = priviliges{
            for member in priviliges{
                priviligeDictionary[member.key] = member.value.boolValue
            }
        }
        
        print("members: \(memberDictionary)")
        print("priviliges: \(priviligeDictionary)")
        
        var items: [Item] = []
        
        if let content = content{
            print(content)
            for element in content{
                print("element \(element)")
                let status = element.value.dictionaryValue["status"]?.boolValue
                let by = element.value.dictionaryValue["by"]?.stringValue
                let text = element.value.dictionaryValue["text"]?.stringValue
                let userId = element.value.dictionaryValue["userId"]?.stringValue
                
                if let status = status, let by = by, let text = text, let userId = userId{
                    let item = Item(text: text, status: status, by: by, userId: userId)
                    items.append(item)
                }
            }
        }
        
        print("all items: \(items)")
        
        if let title = title, let initiator = initiator{
            let shoppingList = ShoppingList(listId: listId, title: title, members: memberDictionary, initiator: initiator, createdAt: nil, content: items, priviliges: priviligeDictionary)
            return shoppingList
        }
        return nil
    }
    
    static func loadShoppingList(mode: WatchType = .subscribe,listId: String, completion: @escaping (ShoppingList)->()) -> DatabaseHandle? {
        if mode == .subscribe{
            let ref: DatabaseHandle = FirebaseHelper.getRealtimeDB().child("lists").child(listId).observe(.value) { (snapshot) in
                // transform snapshot data to json
                let data = JSON(snapshot.value)
                // pass to function to create shopping list from it
                let shoppingList = createShoppingListFromJSON(listId: listId, data: data)
                if let shoppingList = shoppingList {
                    completion(shoppingList)
                }
            }
            return ref
        }else if mode == .load{
            FirebaseHelper.getRealtimeDB().child("lists").child(listId).observeSingleEvent(of: .value) { (snapshot) in
                // transform snapshot data to json
                let data = JSON(snapshot.value)
                // pass to function to create shopping list from it
                let shoppingList = createShoppingListFromJSON(listId: listId, data: data)
                if let shoppingList = shoppingList {
                    completion(shoppingList)
                }
            }
            return nil
        }
        return nil
    }
}

enum WatchType{
    case subscribe, load
}

extension ShoppingList{
    func toJson(){
        
    }
}
