//
//  Profile.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Recover: MYViewController, UIWebViewDelegate {
    
    @IBOutlet private var webView: UIWebView!
    let url = URL.init(string: "http://mysteryclient.mebius.it/login/retrieve-password")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestObj = URLRequest.init(url: self.url!)
        
        self.webView.loadRequest(requestObj)
        self.webView.becomeFirstResponder()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url == url { // || request.url! == URL.init(string: Config.basePath) {
            return true
        }
        self.navigationController?.popToRootViewController(animated: true)
        return false
    }
}
