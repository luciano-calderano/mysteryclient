//
//  SubLabel.swift
//  MysteryClient
//
//  Created by mac on 29/08/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubLabel: KpiQuestSubView, UITextFieldDelegate {
    class func Instance() -> SubLabel {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubLabel
    }
    
    @IBOutlet private var kpiLabel: MYLabel!
    
    override func initialize(kpiResult: JobResult.KpiResult, valuations: [Job.Kpi.Valuations]) {
        super.initialize(kpiResult: kpiResult, valuations: valuations)
        self.kpiLabel.text = kpiResult.value
    }
}


