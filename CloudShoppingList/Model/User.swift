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

enum FirestoreData{
    static let userCollection: String = "users"
    static let profilePicStorage: String = "userProfilPictures"
    static let groupCollection: String = "groups"
}

class User{
    
    var id: String
    var username: String
    var mail: String
    var pic: String
    var picPath: String
    var status: String?
    
    init(id: String, username: String, mail: String, pic: String, picPath: String, status: String){
        self.id = id
        self.username = username
        self.mail = mail
        self.pic = pic
        self.picPath = picPath
        self.status = status
    }
    
    init(userId: String, data: Dictionary<String, Any>){
        self.id = userId
        self.username = data["username"] as! String
        self.mail = data["mail"] as! String
        self.pic = data["pic"] as! String
        self.picPath = data["picPath"] as! String
        self.status = data["status"] as? String
    }
    
    private func transformData(email: String, name: String, downloadPath: String, picPath: String, status: String?, updateStatus: UpdateStatus) ->
        Dictionary<String,Any>{
            switch updateStatus{
            case .initialWrite:
                let data: Dictionary<String,Any> =
                    [
                        "mail": email,
                        "username": name,
                        "pic": downloadPath,
                        "picPath": picPath,
                        "status": status as Any,
                        "timestamp": FieldValue.serverTimestamp(),
                        "updated": FieldValue.serverTimestamp()
                ]
                return data
            case .update:
                let data: Dictionary<String,Any> =
                    [
                        "mail": email,
                        "username": name,
                        "pic": downloadPath,
                        "picPath": picPath,
                        "status": status as Any,
                        "updated": FieldValue.serverTimestamp()
                ]
                return data
            }
    }
    
    static func retrieveUser(userId: String, completion: @escaping (User?)->()){
        let docRef = FirebaseHelper.getDb().collection(FirestoreData.userCollection).document(userId)
        docRef.getDocument { (document, error) in
            if let documentId = document?.documentID, let _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    let user = User(userId: documentId, data: data)
                    print("user: \(user)")
                    completion(user)
                })
            }) {
            } else {
                completion(nil)
                print("Document does not exist")
            }
        }
    }
    
    static func retrieveUserListener(userId: String, completion: @escaping (User?) -> ()) -> ListenerRegistration{
        let listener = FirebaseHelper.getDb().collection(FirestoreData.userCollection).document(userId).addSnapshotListener { (snap, error) in
            if let error = error{
                print("user retrieve error: \(error)")
                completion(nil)
            }else{
                if let data = snap?.data(){
                    let user = User(userId: userId, data: data)
                    completion(user)
                }else{
                    completion(nil)
                }
            }
        }
        return listener
    }
    
    func update(completion: @escaping ()->()){
        let userRef = FirebaseHelper.getDb().collection(FirestoreData.userCollection).document(self.id)
        userRef.updateData(transformData(email: self.mail, name: self.username, downloadPath: self.pic, picPath: self.picPath, status: self.status, updateStatus: .update)) { (error) in
            if let error = error{
                print("Error updating document: \(error)")
            }else{
                print("Document successfully updated")
                completion()
            }
        }
    }
    
    func save(completion: @escaping ()->()){
        let userRef = FirebaseHelper.getDb().collection(FirestoreData.userCollection).document(self.id)
        userRef.setData(transformData(email: self.mail, name: self.username, downloadPath: self.pic, picPath: self.picPath, status: self.status, updateStatus: .initialWrite)) { (error) in
            if let error = error{
                print("Error updating document: \(error)")
            }else{
                print("Document successfully updated")
                completion()
            }
        }
    }
}
