//
//  KpiPageFirst.swift
//  MysteryClient
//
//  Created by mac on 06/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiPageLast: KpiPageView, UITextViewDelegate {
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
        self.finalText.layer.borderColor = UIColor.lightGray.cgColor
        self.finalText.layer.borderWidth = 1
        self.finalText.delegate = self
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if Config.jobResult.compilation_date.isEmpty == false {
            let d = Config.jobResult.compilation_date
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}
