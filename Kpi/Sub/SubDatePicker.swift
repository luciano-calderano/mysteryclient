//
//  SubDatePicker.swift
//  MysteryClient
//
//  Created by mac on 11/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubDatePicker: KpiPageSubView, UIPickerViewDelegate {
    class func Instance() -> SubDatePicker {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubDatePicker
    }
    
    @IBOutlet private var kpiPicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.kpiPicker.addTarget(self, action: #selector(pickerUpdate(sender:)),
                                 for: UIControlEvents.valueChanged)

    }
    
    override func initialize(kpiResult: JobResult.KpiResult, valuations: [Job.Kpi.Valuations]) {
        super.initialize(kpiResult: kpiResult, valuations: valuations)
        self.value = kpiResult.value
        self.kpiPicker.date = kpiResult.value.toDate(withFormat: Date.fmtDataOraJson)
        self.delegate?.subViewResized(newHeight: self.frame.size.height)
    }
    
    
    func pickerUpdate(sender: UIDatePicker) {
        self.value = self.kpiPicker.date.toString(withFormat: Date.fmtDataOraJson)
    }

}


