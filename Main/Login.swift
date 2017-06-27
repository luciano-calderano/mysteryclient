//
//  Login.swift
//  MysteryClient
//
//  Created by Lc on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

typealias JsonDict = Dictionary<String, Any>

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
    var saveCred = false

    private var myWheel: MYWheel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginView.isHidden = true
        self.checkImg = self.saveCredButton.image(for: .normal)
        self.saveCredButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)

        self.userView.layer.cornerRadius = self.userView.frame.size.height / 2
        self.passView.layer.cornerRadius = self.passView.frame.size.height / 2
        
        self.saveCredButton.setImage(nil, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.myWheel = MYWheel()
        self.myWheel?.start(self.view)

        let credential = User.shared.credential()
        self.userText.text = credential.user
        self.passText.text = credential.pass
//        self.userText.text = "utente_gen"
//        self.passText.text = "novella44"
        self.saveCred = !credential.user.isEmpty
        self.updateCheckCredential()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if User.shared.getToken().isEmpty {
            self.loginView.isHidden = false
        }
        else {
            self.userLogged()
        }
        self.myWheel?.stop()
        self.myWheel = nil
    }

    @IBAction func saveCredTapped () {
        self.saveCred = !self.saveCred
        self.updateCheckCredential()
    }

    @IBAction func credRecoverTapped () {
        
        let ctrl = WebPage.Instance(type: .recover)
//
//        let sb = UIStoryboard.init(name: "Recover", bundle: nil)
//        let ctrl = sb.instantiateInitialViewController()
        self.navigationController?.show(ctrl, sender: self)
    }
    
    @IBAction func signInTapped () {
        if self.userText.text!.isEmpty {
            self.userText.becomeFirstResponder()
            return
        }
        if self.passText.text!.isEmpty {
            self.passText.becomeFirstResponder()
            return
        }
        self.view.endEditing(true)

        User.shared.checkUser(saveCredential: self.saveCred,
                              userName: self.userText.text!,
                              password: self.passText.text!,
                              completion: { Bool in
                                self.userLogged()
                                
        }) { (errorCode, message) in
            self.alert("Error: \(errorCode)", message: message, okBlock: nil)
        }
    }
    @IBAction func signUpTapped () {
        let ctrl = WebPage.Instance(type: .register)
        self.navigationController?.show(ctrl, sender: self)
    }
    
    //MARK: - private
    
    private func updateCheckCredential() {
        let img: UIImage? = self.saveCred == true ? self.checkImg : nil
        self.saveCredButton.setImage(img, for: .normal)
    }
    
    private func userLogged () {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.navigationController?.show(vc!, sender: self)
    }
    
    //MARK: - text field delegate
    
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
}
