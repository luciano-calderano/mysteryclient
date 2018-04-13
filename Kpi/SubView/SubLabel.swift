//
//  SubLabel.swift
//  MysteryClient
//
//  Created by mac on 29/08/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubLabel: KpiBaseSubView, UITextFieldDelegate {
    class func Instance() -> SubLabel {
        let id = "SubLabel"
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubLabel
    }
    override var kpiResult: JobResult.KpiResult? {
        didSet {
            if let value = kpiResult?.value {
                kpiLabel.text = value
            }
            delegate?.kpiViewHeight(self.frame.size.height)
        }
    }

    @IBOutlet private var kpiLabel: MYLabel!
}

