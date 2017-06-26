//
//  Profile.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class IncarichiHome: MYViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    
    // MARK: - private
    
    private func loadData() {
        let request = MYHttpRequest.get("rest/get")
    
        request.json = [
            "object" : "jobs",
        ]
        request.start() { (result, response) in
            let code = response.int("code")
            if code == 200 && response.string("status") == "ok" {
            }
        }

    }
}
