//
//  AuthenticationController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 14.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation
import FirebaseAuth

struct AuthenticationController{
    
    static func registerUser(withName: String, email: String, password: String, completion: @escaping (User?) -> Swift.Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                
                guard let user = user else{
                    NotificationUtility.showPrettyMessage(with: "Es ist ein Fehler aufgetreten", button: "ok", style: .error)
                    completion(nil)
                    return
                }
                
                user.user.sendEmailVerification(completion: nil)
                
                let usr = User(id: user.user.uid, username: withName, mail: email)
                                
                usr.save {
                    completion(usr)
                }
                
                
            }else {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    print(errCode)
                    switch errCode{
                    case .emailAlreadyInUse:
                        NotificationUtility.showPrettyMessage(with: "E-Mail Adresse bereits registriert", button: "ok", style: .error)
                        break
                    case .weakPassword:
                        NotificationUtility.showPrettyMessage(with: "Bitte wähle ein Passwort mit mindestens 6 Zeichen", button: "ok", style: .error)
                    default:
                        break
                    }
                }
                completion(nil)
            }
        })
    }
    static func loginUser(withEmail: String, password: String, completion: @escaping (String?)->()) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            if error == nil {
                if let user = user{
                    let verificationStatus: Bool = user.user.isEmailVerified
                    if verificationStatus{
                        let userInfo = ["userid": user.user.uid, "email": withEmail, "password": password]
                        self.setUserLocalData(userInfo)
                        completion(user.user.uid)
                    }else {
                        NotificationUtility.showPrettyMessage(with: "Bitte bestätige zuerst deine E-Mail Adresse", button: "ok", style: .error)
                        completion(nil)
                    }
                }
                
            } else {
                if error != nil{
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        switch errCode{
                        case .invalidEmail:
                            NotificationUtility.showPrettyMessage(with: "Die eingegeben Benutzerdaten sind falsch", button: "ok", style: .error)
                            break
                        case .wrongPassword:
                            NotificationUtility.showPrettyMessage(with: "Die eingegeben Benutzerdaten sind falsch", button: "ok", style: .error)
                            break
                        default:
                            break
                        }
                    }
                }
                completion(nil)
            }
        })
    }
    
    static func logOutUser(completion: @escaping (Bool) -> Swift.Void) {
        do {
            try Auth.auth().signOut()
            NotificationListenerController.shared.stopListening()
            UserDefaults.standard.removeObject(forKey: "userInformation")
            completion(true)
        } catch _ {
            completion(false)
        }
    }
    
    private static func setUserLocalData(_ userInfo: Dictionary<String,String>){
        UserDefaults.standard.set(userInfo, forKey: "userInformation")
        print(UserDefaults.standard.dictionary(forKey: "userInformation")!)
    }
}
