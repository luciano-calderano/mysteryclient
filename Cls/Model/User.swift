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
    
    func getUser () -> String {
        let userDefault = UserDefaults.standard
        let user = userDefault.string(forKey: self.userKey)
        return (user == nil || (user?.isEmpty)!) ? "" : user!
    }

    func saveUser(user: String) {
        let userDefault = UserDefaults.standard
        userDefault.set(user, forKey: self.userKey)
    }
    
    func logout() {
        let userDefault = UserDefaults.standard
        userDefault.set("", forKey: self.userKey)
    }
}
