//
//  Login.swift
//  MisteryClient
//
//  Created by Lc on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

typealias JsonDict = Dictionary<String, Any>
let webUrl = "www.mebius.it"

class Login: MYViewController, UITextFieldDelegate {
    class func Instance() -> Login {
        let vc = self.load(storyboardName: "Main") as! Login
        return vc
    }
    @IBOutlet var loginView: UIView!
    
    @IBOutlet var userView: UIView!
    @IBOutlet var passView: UIView!
    
    @IBOutlet var userText: MYTextField!
    @IBOutlet var passText: MYTextField!

    @IBOutlet var saveCredButton: MYButton!
    var checkImg: UIImage?
    var saveCred = true

    private var myWheel: MYWheel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginView.isHidden = true
        self.checkImg = self.saveCredButton.image(for: .normal)
        self.saveCredButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)

        self.userView.layer.cornerRadius = self.userView.frame.size.height / 2
        self.passView.layer.cornerRadius = self.passView.frame.size.height / 2
        
        self.userText.text = "utente_gen"
        self.passText.text = "novella44"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.myWheel = MYWheel()
        self.myWheel?.start(self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let userName = User.shared.getUser()
        if userName.isEmpty {
            self.loginView.isHidden = false
        }
        else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main")
            self.navigationController?.show(vc!, sender: self)
        }
        self.myWheel?.stop()
        self.myWheel = nil
    }

    @IBAction func saveCredTapped () {
        if self.saveCred == true {
            self.saveCredButton.setImage(nil, for: .normal)
            self.saveCred = false
        }
        else {
            self.saveCredButton.setImage(self.checkImg, for: .normal)
            self.saveCred = true
        }
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
            User.shared.saveUser(user: self.userText.text!,
                                 pass: self.passText.text!,
                                 token: dict.string("token"))
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main")
            self.navigationController?.show(vc!, sender: self)
            return
        }
        self.alert("Error: \(code)", message: msg, okBlock: nil)
    }
}
