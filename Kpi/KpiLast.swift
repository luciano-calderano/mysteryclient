//
//  KpiLast.swift
//  MysteryClient
//
//  Created by mac on 10/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiLast: KpiViewController, UITextViewDelegate {
    override class func Instance() -> KpiLast {
        let vc = self.load(storyboardName: "Kpi") as! KpiLast
        return vc
    }
    
    @IBOutlet private var finalView: UIView!
    @IBOutlet private var finalText: UITextView!
    @IBOutlet private var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.finalText.text = MYJob.shared.jobResult.comment
        self.finalText.layer.borderColor = UIColor.lightGray.cgColor
        self.finalText.layer.borderWidth = 1
        self.finalText.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MYJob.shared.jobResult.compilation_date.isEmpty == false {
            let d = MYJob.shared.jobResult.compilation_date
            let date = d.toDate(withFormat: Date.fmtDataOraJson)
            self.datePicker.date = date
        }
    }
    
    override func checkData() -> KpiResultType {
        MYJob.shared.jobResult.comment = self.finalText.text!
        MYJob.shared.jobResult.compiled = 1
        MYJob.shared.jobResult.compilation_date = self.datePicker.date.toString(withFormat: Date.fmtDataOraJson)
        MYJob.shared.jobResult.execution_end_time = self.datePicker.date.toString(withFormat: Date.fmtOra)
        MYJob.shared.saveResult()
        
        return .last
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
