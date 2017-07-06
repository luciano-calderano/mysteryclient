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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.undondeText.text = Config.jobResult.comment
        if Config.jobResult.execution_date.isEmpty == false {
            let d = Config.jobResult.execution_date + " " + Config.jobResult.execution_start_time + ":00"
            self.datePicker.date = d.toDate(withFormat: Date.fmtDataOraJson)
        }
    }
    
    override func checkData() -> KpiResultType {
        if self.undoneView.isHidden == false {
            if (self.undondeText.text?.isEmpty)! {
                self.undondeText.becomeFirstResponder()
                return .err
            }
            Config.jobResult.comment = self.undondeText.text!
            Config.jobResult.compiled = 1
            Config.jobResult.save()
            return .next
        }
        
        Config.jobResult.execution_date = self.datePicker.date.toString(withFormat: Date.fmtDataJson)
        Config.jobResult.execution_start_time = self.datePicker.date.toString(withFormat: Date.fmtOra)
        Config.jobResult.save()

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
