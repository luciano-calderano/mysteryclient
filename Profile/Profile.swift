//
//  Profile.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Profile: MYViewController {
    
    @IBOutlet private var tableView: UITableView!
//    @IBOutlet private var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()

//        let url = URL.init(string: "http://mysteryclient.mebius.it/mystery/edit")
//        var requestObj = URLRequest.init(url: self.url!)
//        let token = User.shared.getToken()
//        requestObj.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
//        self.webView.loadRequest(requestObj)

    }
    
//    override func headerViewSxTapped() {
//    }
//    
    // MARK: - private
    
    private func loadData() {
        let request = MYHttpRequest.get("rest/get")
    
        request.json = [
            "object" : "profile",
        ]
        request.start() { (result, response) in
            let code = response.int("code")
            if code == 200 && response.string("status") == "ok" {
            }
        }

    }
}
