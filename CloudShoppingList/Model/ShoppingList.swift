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
    
    init(listId: String, title: String, members: [String:Bool], initiator: String, createdAt: TimeInterval?){
        self.listId = listId
        self.title = title
        self.members = members
        self.initiator = initiator
        self.createdAt = createdAt
    }
    
    static func createShoppingList(title: String, completion: @escaping ()->()){
        let newListJson: [String:Any] = [
            "content": [:],
            "title": title,
            "initiator": Me.uid,
            "members": [Me.uid: true],
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
        let list = ShoppingList.loadShoppingList(listId: listId) { (list) in
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
                completion()
            }
        }
    }
    
    static func loadShoppingList(listId: String, completion: @escaping (ShoppingList)->()){
        _ = FirebaseHelper.getRealtimeDB().child("lists").child(listId).observeSingleEvent(of: .value) { (snapshot) in
            let data = JSON(snapshot.value).dictionaryValue
            
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
            
            print("members: \(memberDictionary)")
            
            var items: [Item] = []
            
            if let content = content{
                for item in content{
                    let by = item.value.dictionaryValue["by"]?.stringValue
                    let text = item.value.dictionaryValue["text"]?.stringValue
                    let status = item.value.dictionaryValue["status"]?.boolValue
                    let item = Item(text: text!, status: status!, by: by!)
                    items.append(item)
                    print("item \(item)")
                }
            }
            print("all items: \(items)")
            
            if let title = title, let initiator = initiator{
                let shoppingList = ShoppingList(listId: listId, title: title, members: memberDictionary, initiator: initiator, createdAt: nil)
                completion(shoppingList)
            }
            
        }
    }
}

extension ShoppingList{
    func toJson(){
        
    }
}
