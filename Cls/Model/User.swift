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
    private let kTkn = "keyToken"
    
    var userData = [String: String]()
    
    private let grant_type = "password"
    private let client_id = "mystery_app"
    private let client_secret = "UPqwU7vHXGtHk6JyXrA5"
    
    override init() {
        super.init()
        self.userData[kUsr] = ""
        self.userData[kPwd] = ""
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
        let request = MYHttpRequest.post("oauth/grant")
        request.json = [
            "grant_type"   : self.grant_type,
            "client_id"    : self.client_id,
            "client_secret": self.client_secret,
            "username"     : userName,
            "password"     : password,
        ]
        request.start() { (result, response) in
            let code = response.int("code")
            if code == 200 && response.string("status") == "ok"{
                let dict = response.dictionary("token")
                self.userData[self.kTkn] = dict.string("access_token")

                if saveCredential == true {
                    self.userData[self.kUsr] = userName
                    self.userData[self.kPwd] = password
                }
                else {
                    self.userData[self.kUsr] = ""
                    self.userData[self.kPwd] = ""
                }
                self.saveUserData()
                completion ()
            }
            else {
                failure(code, response.string("message"))
            }
        }
    }
}
