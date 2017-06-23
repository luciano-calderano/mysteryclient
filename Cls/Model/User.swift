//
//  User.swift
//  MisteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

class User: NSObject {
    static let shared = User()
    
    private let userKey = "userKey"
    
    var user = ""
    var pass = ""
    var token = ""
    
    func getUser () -> String {
        let userDefault = UserDefaults.standard
        let user = userDefault.string(forKey: self.userKey)
        return (user == nil || (user?.isEmpty)!) ? "" : user!
    }

    func saveUser(user: String, pass: String, token: String) {
        let userDefault = UserDefaults.standard
        userDefault.set(user, forKey: self.userKey)
        self.user = user
        self.pass = pass
        self.token = token
    }
    
    func logout() {
        let userDefault = UserDefaults.standard
        userDefault.set("", forKey: self.userKey)
        self.user = ""
        self.pass = ""
        self.token = ""
    }
    
    func checkUser (saveCredential: Bool, userName: String, password: String,
                    completion: @escaping () -> () = { success in },
                    failed: @escaping (Int, String) -> () = { errorCode, message in }) {
        let token = "UPqwU7vHXGtHk6JyXrA5"
        let request = MYHttpRequest.get("oauth/grant")
        request.json = [
            "grant_type"   : "password",
            "client_id"    : "mistery_app",
            "client_secret": token,
            "username"     : userName,
            "password"     : password,
        ]
        request.start() { (result, response) in
            let code = response.int("code")
            //        let status = dict.string("status")
            if code == 200 {
                self.token = response.string("token")
                if saveCredential == true {
                    self.user = userName
                    self.pass = password
                }
                completion ()
            }
            else {
                failed(code, response.string("message"))
            }
        }
    }
}
