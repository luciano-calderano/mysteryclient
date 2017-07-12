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
        self.finalText.text = Config.jobResult.comment
        self.finalText.layer.borderColor = UIColor.lightGray.cgColor
        self.finalText.layer.borderWidth = 1
        self.finalText.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        Config.jobResult.execution_end_time = self.datePicker.date.toString(withFormat: Date.fmtOra)
        Config.jobResult.save()
        
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
