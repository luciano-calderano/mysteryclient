//
//  Login.swift
//  MisteryClient
//
//  Created by Lc on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Login: MYViewController, UITextFieldDelegate {
    class func Instance() -> Login {
        let vc = self.load(storyboardName: "Main") as! Login
        return vc
    }
    @IBOutlet var userView: UIView!
    @IBOutlet var passView: UIView!
    
    @IBOutlet var userText: MYTextField!
    @IBOutlet var passText: MYTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userView.layer.cornerRadius = self.userView.frame.size.height / 2
        self.passView.layer.cornerRadius = self.passView.frame.size.height / 2
        
        self.userText.text = "Utente"
        self.passText.text = "Passwd"
    }
    
    @IBAction func loginTapped () {
        if self.userText.text!.isEmpty {
            self.userText.becomeFirstResponder()
            return
        }
        if self.passText.text!.isEmpty {
            self.passText.becomeFirstResponder()
            return
        }
        self.view.endEditing(true)
        self.checkUser()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.userText {
            self.passText.becomeFirstResponder()
            return true
        }
        if textField == self.passText {
            self.view.endEditing(true)
        }
        return true
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
            self.httpResponse(dict: response)
        }
    }
    
    private func httpResponse (dict: JsonDict) {
        print (dict)
        let code = dict.int("code")
//        let status = dict.string("status")
        let msg = dict.string("message")
        if code == 200 {
            User.shared.saveUser(user: self.userText.text!)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main")
            self.navigationController?.show(vc!, sender: self)
            return
        }
        self.alert("Error: \(code)", message: msg, okBlock: nil)
    }
}
