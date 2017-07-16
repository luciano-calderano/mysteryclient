//
//  KpiStart.swift
//  MysteryClient
//
//  Created by mac on 10/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiStart: KpiViewController {
    override class func Instance() -> KpiStart {
        let vc = self.load(storyboardName: "Kpi") as! KpiStart
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
        
        self.undondeText.text = MYJob.shared.jobResult.comment
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MYJob.shared.jobResult.execution_date.isEmpty == false {
            let d = MYJob.shared.jobResult.execution_date + " " + MYJob.shared.jobResult.execution_start_time + ":00"
            let date = d.toDate(withFormat: Date.fmtDataOraJson)
            self.datePicker.date = date
        }
    }
    
    override func checkData() -> KpiResultType {
        if self.undoneView.isHidden == false {
            if (self.undondeText.text?.isEmpty)! {
                self.undondeText.becomeFirstResponder()
                return .errNotes
            }
            MYJob.shared.jobResult.comment = self.undondeText.text!
            MYJob.shared.jobResult.compiled = 1
            MYJob.shared.saveResult()
            return .last
        }

        MYJob.shared.jobResult.execution_date = self.datePicker.date.toString(withFormat: Date.fmtDataJson)
        MYJob.shared.jobResult.execution_start_time = self.datePicker.date.toString(withFormat: Date.fmtOra)
        MYJob.shared.saveResult()
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
