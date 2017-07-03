//
//  KpisDetail
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpisDetail: MYViewController {
    class func Instance(job: Job, index: Int) -> KpisDetail {
        let vc = self.load(storyboardName: "Jobs") as! KpisDetail
        vc.job = job
        vc.index = index
        return vc
    }

    var job: Job!
    var index = 0
    
    private var kpi: Kpi!
    
    @IBOutlet private var scroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.kpi = self.job.kpis[index]
        switch self.kpi.type {
        case "radio" :
            let sub = KpiRadio.Instance()
            sub.kpi = self.kpi
            self.scroll.addSubviewWithConstraints(sub)
        default:
            return
        }
    }
}


