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
        let id = "SubLabel"
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubLabel
    }
    
    @IBOutlet private var kpiLabel: MYLabel!
    
    override func initialize(kpiIndex: Int) {
        super.initialize(kpiIndex: kpiIndex)
        kpiLabel.text = kpiResult.value
    }
}


