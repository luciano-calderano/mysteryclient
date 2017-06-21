//
//  Login.swift
//  MisteryClient
//
//  Created by Lc on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Login: MYViewController {
    class func Instance() -> Login {
        let vc = self.load(storyboardName: "Main") as! Login
        return vc
    }
    
    @IBOutlet var userText: MYTextField!
    @IBOutlet var passText: MYTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userText.text = "Utente"
        self.passText.text = "Passwd"
    }
    
    @IBAction func loginTapped () {
        if self.userText.text!.isEmpty {
            return
        }
        if self.passText.text!.isEmpty {
            return
        }
        self.checkUser()
    }
    
    private func checkUser () {
        let token = "UPqwU7vHXGtHk6JyXrA5"
        let request = MYHttpRequest.get("oauth/grant")
        request.json = [
            "grant_type"   : "password",
            "client_id"    : "mistery_app",
            "client_secret": token,
            "username"     : self.userText.text!,
            "password"     : self.passText.text!,
        ]
        request.start() { (result, response) in
            print (response)
            self.httpResponse(dict: [:])
        }
    }
    
    private func httpResponse (dict: JsonDict) {
        User.shared.saveUser(user: self.userText.text!)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main")
        self.navigationController?.show(vc!, sender: self)

    }
}
