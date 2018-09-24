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

// stuct to represent a shopping list
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
    
    // adds a item to the shopping list
    mutating func addItem(item: Item, userId: String, success: ()->()){
        if (checkPrivilige(userId)){
            content.append(item)
            FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("content").childByAutoId().updateChildValues(item.toDictionary())
            success()
        }else{
            NotificationUtility.showPrettyMessage(with: "Du hast keine Berechtigungen Positionen hinzuzufügen", button: "ok", style: .error)
        }
    }
    
    // adds a member to the shopping list
    mutating func addMember(userId: String){
        // make local changes
        members[userId] = false
        priviliges[userId] = false
        // persist to firebase
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("members").updateChildValues([userId: false])
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("priviliges").updateChildValues([userId: false])
    }
    
    // removes a member from the shopping list
    mutating func removeMember(userId: String){
        // make local changes
        members[userId] = nil
        priviliges[userId] = nil
        // persist to firebase
        FirebaseHelper.getRealtimeDB().child("users").child(userId).child("lists").child(self.listId).removeValue()
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("members").child(userId).setValue(nil)
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("priviliges").child(userId).setValue(nil)
    }
    
    // changes the title of the shopping list
    mutating func changeTitle(newTitle: String){
        // make local changes
        self.title = newTitle
        // persist to firebase
        persistTitle()
    }
    
    // removes an item from the shopping list
    mutating func removeItem(at index: Int){
        let firebaseId = self.content[index].itemId
        self.content.remove(at: index)
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("content").child(firebaseId).setValue(nil)
    }
    
    // checks the specified item with itemId in the shopping list
    mutating func checkItem(_ itemId: String){
        var item = content.first { (item) -> Bool in
            item.itemId == itemId
        }
        item?.status = true
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("content").child(itemId).updateChildValues(["status":true])
    }
    
    // unchecks the specified item with itemId in the shopping list
    mutating func uncheckItem(_ itemId: String){
        var item = content.first { (item) -> Bool in
            item.itemId == itemId
        }
        item?.status = false
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("content").child(itemId).updateChildValues(["status":false])
    }
    
    private func persistTitle(){
        // change title of list itself
        FirebaseHelper.getRealtimeDB().child("lists").child(self.listId).child("title").setValue(self.title)
        // change title of all list representations in all users who are members
        for member in self.members{
            // only member = true users
            if member.value{
                FirebaseHelper.getRealtimeDB().child("users").child(member.key).child("lists").child(self.listId).child("title").setValue(self.title)
            }
        }
    }
    
    // checks the priviliges of a given user for the current shopping list
    public func checkPrivilige(_ userId: String) -> Bool{
        return priviliges[userId] == true
    }
    
    // changes the priviliges of a given user for the current shopping list
    // newStatus = true: can check/uncheck items and add new items
    // newStatus = false: can only see the items
    static func changePrivilige(for userId: String, on shoppingListId: String, newStatus: Bool){
        FirebaseHelper.getRealtimeDB().child("lists").child(shoppingListId).child("priviliges").updateChildValues([userId: newStatus])
    }
    
    // creates a new shopping list in the database
    static func createShoppingList(title: String, completion: @escaping ()->()){
        let newListJson: [String:Any] = [
            "content": [:],
            "title": title,
            "initiator": Me.uid,
            "members": [Me.uid: true],
            "priviliges": [Me.uid: true],
            "created": ServerValue.timestamp()
        ]
        // adds a new document to the lists collection
    FirebaseHelper.getRealtimeDB().child("lists").childByAutoId().setValue(newListJson) { (error, ref) in
            if let error = error {
                print(error)
            }else{
                let newListRepresentationJson: [String:Any] = [
                    "title": title,
                    "listId": ref.key
                ]
                // adds a list representation document in the users collection
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
    
    // deletes a shopping list specified by the listId
    static func deleteShoppingList(listId: String){
        FirebaseHelper.getRealtimeDB().child("lists").child(listId).child("members").child(Me.uid).setValue(nil)
        FirebaseHelper.getRealtimeDB().child("lists").child(listId).child("priviliges").child(Me.uid).setValue(nil)
        FirebaseHelper.getRealtimeDB().child("users").child(Me.uid).child("lists").child(listId).setValue(nil)
    }
 
    // creates a new shopping list object from json
    private static func createShoppingListFromJSON(listId: String, data: JSON) -> ShoppingList?{
        let data = data.dictionaryValue
        var memberDictionary: [String:Bool] = [:]
        let initiator = data["initiator"]?.stringValue
        let title = data["title"]?.stringValue
        let content = data["content"]?.dictionaryValue
        let members = data["members"]?.dictionaryValue
        var priviligeDictionary: [String:Bool] = [:]
        let priviliges = data["priviliges"]?.dictionaryValue
        
        if let members = members{
            for member in members{
                memberDictionary[member.key] = member.value.boolValue
            }
        }
    
        if let priviliges = priviliges{
            for member in priviliges{
                priviligeDictionary[member.key] = member.value.boolValue
            }
        }
    
        var items: [Item] = []
        
        if let content = content{
            for element in content{
                let itemId = element.key
                let status = element.value.dictionaryValue["status"]?.boolValue
                let by = element.value.dictionaryValue["by"]?.stringValue
                let text = element.value.dictionaryValue["text"]?.stringValue
                let userId = element.value.dictionaryValue["userId"]?.stringValue
                
                if let status = status, let by = by, let text = text, let userId = userId{
                    let item = Item(itemId: itemId, text: text, status: status, by: by, userId: userId)
                    items.append(item)
                }
            }
        }
        
        if let title = title, let initiator = initiator{
            let shoppingList = ShoppingList(listId: listId, title: title, members: memberDictionary, initiator: initiator, createdAt: nil, content: items, priviliges: priviligeDictionary)
            return shoppingList
        }
        
        return nil
    }
    
    // loads a shopping list specified by its id
    // mode = subscribe: subscribes to the shopping list in the realtime database and continuously receives updates
    // mode = load: only loads the shopping list once
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
