//
//  KpiLast.swift
//  MysteryClient
//
//  Created by mac on 10/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiLastView: KpiBaseView {
    class func Instance() -> KpiLastView {
        let id = "KpiLastView"
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! KpiLastView
    }
    
    @IBOutlet private var finalView: UIView!
    @IBOutlet private var finalText: UITextView!
    @IBOutlet private var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        finalText.text = MYJob.shared.jobResult.comment
        finalText.layer.borderColor = UIColor.lightGray.cgColor
        finalText.layer.borderWidth = 1
        finalText.delegate = self
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if MYJob.shared.jobResult.compilation_date.isEmpty == false {
            let d = MYJob.shared.jobResult.compilation_date
            let date = d.toDate(withFormat: Config.DateFmt.DataOraJson)
            datePicker.date = date
        }
    }
    
    override func checkData(completion: @escaping (KpiResultType) -> ()) {
        MYJob.shared.jobResult.comment = finalText.text!
        MYJob.shared.jobResult.compiled = 1
        MYJob.shared.jobResult.compilation_date = datePicker.date.toString(withFormat: Config.DateFmt.DataOraJson)
        MYJob.shared.jobResult.execution_end_time = datePicker.date.toString(withFormat: Config.DateFmt.Ora)
        MYResult.shared.saveResult()        
        completion (.last)
    }
}

extension KpiLastView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
