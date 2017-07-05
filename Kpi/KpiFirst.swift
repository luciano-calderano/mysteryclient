//
//  KpiFirst.swift
//  MysteryClient
//
//  Created by mac on 05/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiFirst: KpiViewController {
    class func Instance() -> KpiFirst {
        let vc = self.load(storyboardName: "Kpi") as! KpiFirst
        return vc
    }
    
    @IBOutlet private var undoneView: UIView!
    @IBOutlet private var undondeText: MYTextField!
    @IBOutlet private var okButton: MYButton!
    @IBOutlet private var noButton: MYButton!
    @IBOutlet private var datePicker: UIDatePicker!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        for btn in [self.okButton, self.noButton] {
            btn?.layer.cornerRadius = (btn?.frame.size.height)! / 2
        }
        self.yesTapped()
        self.undondeText.text = self.jobResult.comment
        if self.jobResult.execution_date.isEmpty == false {
            let d = self.jobResult.execution_date + " " + self.jobResult.execution_start_time + ":00"
            self.datePicker.date = d.toDate(withFormat: Date.fmtDataOraJson)
        }
    }
    
    override func checkData() -> KpiResultType {
        if self.undoneView.isHidden == false {
            if (self.undondeText.text?.isEmpty)! {
                self.undondeText.becomeFirstResponder()
                return .err
            }
            self.jobResult.comment = self.undondeText.text!
            self.jobResult.compiled = 1
            self.jobResult.save()
            return .next
        }
        
        self.jobResult.execution_date = self.datePicker.date.toString(withFormat: Date.fmtDataJson)
        self.jobResult.execution_start_time = self.datePicker.date.toString(withFormat: Date.fmtOra)
        self.jobResult.save()

        return .next
    }
    
    // MARK: - Actions
    
    @IBAction func yesTapped () {
        self.undoneView.isHidden = true
        self.okButton.backgroundColor = UIColor.white
        self.noButton.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func noTapped () {
        self.undoneView.isHidden = false
        self.okButton.backgroundColor = UIColor.lightGray
        self.noButton.backgroundColor = UIColor.white
    }
}
