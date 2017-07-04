//
//  KpiHome
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiHome: MYViewController {
    class func Instance(job: Job, jobResult: JobResult) -> KpiHome {
        let vc = self.load(storyboardName: "Jobs") as! KpiHome
        vc.job = job
        vc.jobResult = jobResult
        return vc
    }

    @IBOutlet private var undoneView: UIView!
    @IBOutlet private var undoneViewHeight: NSLayoutConstraint!
    @IBOutlet private var undondeText: MYTextField!
    @IBOutlet private var okButton: MYButton!
    @IBOutlet private var noButton: MYButton!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!

    
    var job: Job!
    var jobResult: JobResult!
    private var resultKeys = [Int]()
    private var undoneViewHeightOrig: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        for result in self.jobResult.results {
            self.resultKeys.append(result.kpi_id)
        }

        for btn in [self.backBtn, self.nextBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(12)
            btn.setImage(ico, for: .normal)            
        }
        self.backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        self.nextBtn.semanticContentAttribute = .forceRightToLeft
        self.nextBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)

        for btn in [self.okButton, self.noButton] {
            btn?.layer.cornerRadius = (btn?.frame.size.height)! / 2
        }
        self.undoneViewHeightOrig = self.undoneViewHeight.constant
        self.yesTapped()
    }

    // MARK: - Actions
    
    @IBAction func yesTapped () {
        self.undoneView.isHidden = true
        self.undoneViewHeight.constant = 0
        self.okButton.backgroundColor = UIColor.white
        self.noButton.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func noTapped () {
        self.undoneView.isHidden = false
        self.undoneViewHeight.constant = self.undoneViewHeightOrig
        self.okButton.backgroundColor = UIColor.lightGray
        self.noButton.backgroundColor = UIColor.white
    }
    
    @IBAction func nextTapped () {
        if self.undoneViewHeight.constant > 0 {
            if (self.undondeText.text?.isEmpty)! {
                self.undondeText.becomeFirstResponder()
                return
            }
            self.jobResult.comment = self.undondeText.text!
            self.jobResult.compiled = 1
            self.jobResult.save()
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        self.jobResult.execution_date = self.datePicker.date.toString(withFormat: Date.fmtDataJson)
        self.jobResult.execution_start_time = self.datePicker.date.toString(withFormat: Date.fmtOra)
        self.jobResult.save()

        let vc = KpisDetail.Instance(job: self.job, index: 0)
        self.navigationController?.show(vc, sender: self)
    }
    @IBAction func prevTapped () {
        self.navigationController?.popViewController(animated: true)
    }
}
