//
//  User.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

class User: NSObject {
    static let shared = User()
    
    private let userKey = "userKey"
    private let kUsr = "keyUser"
    private let kPwd = "keyPass"
    private let kSav = "keySave"
    private let kTkn = "keyToken"
    
    var userData = [String: String]()
    
    private let grant_type = "password"
    private let client_id = "mystery_app"
    private let client_secret = "UPqwU7vHXGtHk6JyXrA5"
    
    override init() {
        super.init()
        self.userData[kUsr] = ""
        self.userData[kPwd] = ""
        self.userData[kSav] = ""
        self.userData[kTkn] = ""

        let userDefault = UserDefaults.standard
        let userData = userDefault.dictionary(forKey: self.userKey)
        if (userData != nil) {
            self.userData = userData as! [String : String]
        }
    }

    private func saveUserData () {
        let userDefault = UserDefaults.standard
        userDefault.set(self.userData, forKey: self.userKey)
    }
    
    func credential () -> (user: String, pass: String) {
        if self.userData[self.kSav] != "1" {
            return ("", "")
        }
        return (self.userData[self.kUsr]!, self.userData[self.kPwd]!)
    }
    
    func getToken() -> String {
        return self.userData[self.kTkn]!
    }
    
    func logout() {
        self.userData[self.kTkn] = ""
        self.saveUserData()
    }
    
    func checkUser (saveCredential: Bool, userName: String, password: String,
                    completion: @escaping () -> () = { success in },
                    failure: @escaping (Int, String) -> () = { errorCode, message in }) {
        self.userData[self.kUsr] = userName
        self.userData[self.kPwd] = password
        self.userData[self.kSav] = saveCredential ? "1" : "0"
        self.userData[self.kTkn] = ""
        self.saveUserData()
        
        self.getUserToken(completion: { 
            completion()
        }) { (errorCode, message) in
            failure(errorCode, message)
        }
    }
    
    func getUserToken(completion: @escaping () -> () = { success in },
                      failure: @escaping (Int, String) -> () = { errorCode, message in }) {
        let request = MYHttpRequest("oauth/grant")
        request.json = [
            "grant_type"   : self.grant_type,
            "client_id"    : self.client_id,
            "client_secret": self.client_secret,
            "username"     : self.userData[self.kUsr]!,
            "password"     : self.userData[self.kPwd]!,
        ]
        request.get(header: false) { (result, response) in
            let code = response.int("code")
            if code == 200 && response.string("status") == "ok"{
                let dict = response.dictionary("token")
                self.userData[self.kTkn] = dict.string("access_token")
                self.saveUserData()
                completion ()
            }
            else {
                failure(code, response.string("message"))
            }
        }
    }
}
