//
//  Loader.swift
//  MisteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

typealias JsonDict = Dictionary<String, Any>
let webUrl = "www.mebius.it"

class Loader: MYViewController {
    var myWheel: MYWheel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LanguageClass.shared.selectLanguage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startWheel(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.perform(#selector (gotoNextCtrl), with: nil, afterDelay: 0.3)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startWheel(false)
    }
    
    func gotoNextCtrl () {
        let user = User.shared.getUser()
        let ctrl = user.isEmpty ? "Login" : "Main"
        let vc = self.storyboard?.instantiateViewController(withIdentifier: ctrl)
        self.navigationController?.show(vc!, sender: self)
    }
    
    private func startWheel(_ start: Bool, show: Bool = true, inView: UIView = UIApplication.shared.keyWindow!) {
        guard show else {
            return
        }
        if start {
            self.myWheel = MYWheel()
            self.myWheel?.start(inView)
        }
        else {
            self.myWheel?.stop()
            self.myWheel = nil
        }
    }

}
