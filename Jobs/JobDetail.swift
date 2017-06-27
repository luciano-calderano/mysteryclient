//
//  JobDetail.swift
//  MysteryClient
//
//  Created by mac on 27/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class JobDetail: MYViewController {
    class func Instance(job: Job) -> JobDetail {
        let vc = self.load(storyboardName: "Jobs") as! JobDetail
        vc.job = job
        return vc
    }

    var job: Job!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.job)
    }
}

