//
//  Login.swift
//  MysteryClient
//
//  Created by Lc on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Login: MYViewController {
    class func Instance() -> Login {
        return Instance(sbName: "Main", "Login") as! Login
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
    
    //MARK:-

    override func viewDidLoad() {
        super.viewDidLoad()
        print(Config.Path.doc)
        
        loginView.isHidden = true
        checkImg = saveCredButton.image(for: .normal)
        saveCredButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)

        userView.layer.cornerRadius = userView.frame.size.height / 2
        passView.layer.cornerRadius = passView.frame.size.height / 2
        
        saveCredButton.setImage(nil, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myWheel = MYWheel()
        myWheel?.start(view)

        let credential = User.shared.credential()
        userText.text = credential.user
        passText.text = credential.pass
//        userText.text = "utente_gen"
//        passText.text = "novella44"
        saveCred = !credential.user.isEmpty
        updateCheckCredential()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if User.shared.token.isEmpty {
            loginView.isHidden = false
        }
        else {
            userLogged()
        }
        myWheel?.stop()
        myWheel = nil
    }

    @IBAction func saveCredTapped () {
        saveCred = !saveCred
        updateCheckCredential()
    }

    @IBAction func signInTapped () {
        if userText.text!.isEmpty {
            userText.becomeFirstResponder()
            return
        }
        if passText.text!.isEmpty {
            passText.becomeFirstResponder()
            return
        }
        self.view.endEditing(true)

        User.shared.checkUser(saveCredential: saveCred,
                              userName: userText.text!,
                              password: passText.text!,
                              completion: { () in
                                self.userLogged()
                                
        }) { (errorCode, message) in
            self.alert(errorCode, message: message, okBlock: nil)
        }
    }
    @IBAction func signUpTapped () {
        openWeb(type: .register, title: "signUp")
    }

    @IBAction func credRecoverTapped () {
        openWeb(type: .recover, title: "passForg")
    }
    

    //MARK: - private
    
    private func updateCheckCredential() {
        let img: UIImage? = saveCred == true ? checkImg : nil
        saveCredButton.setImage(img, for: .normal)
    }
    
    private func userLogged () {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Home")
        navigationController?.show(vc!, sender: self)
    }
    
    private func openWeb (type: WebPage.WebPageEnum, title: String) {
        let ctrl = WebPage.Instance(type: type)
        navigationController?.show(ctrl, sender: self)
        ctrl.title = Lng(title)
    }
}

//MARK:- UITextFieldDelegate

extension Login: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userText {
            passText.becomeFirstResponder()
            return true
        }
        if textField == passText {
            self.view.endEditing(true)
        }
        return true
    }
}
