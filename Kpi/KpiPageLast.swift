//
//  KpiPageFirst.swift
//  MysteryClient
//
//  Created by mac on 06/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiPageLast: KpiPageView {
    class func Instance() -> KpiPageLast {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! KpiPageLast
    }
    
    @IBOutlet private var finalView: UIView!
    @IBOutlet private var finalText: UITextView!
    @IBOutlet private var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.finalText.text = Config.jobResult.comment
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if Config.jobResult.execution_date.isEmpty == false {
            let d = Config.jobResult.execution_date + " " + Config.jobResult.execution_start_time + ":00"
            let date = d.toDate(withFormat: Date.fmtDataOraJson)
            self.datePicker.date = date
        }
    }
    
    override func checkData() -> KpiResultType {
        Config.jobResult.comment = self.finalText.text!
        Config.jobResult.compiled = 1    
        Config.jobResult.compilation_date = self.datePicker.date.toString(withFormat: Date.fmtDataOraJson)
        Config.jobResult.save()
    
        return .next
    }
}
