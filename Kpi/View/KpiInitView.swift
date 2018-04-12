//
//  SubText
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiInitView: KpiBaseView {
    class func Instance() -> KpiInitView {
        let id = "KpiInitView"
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! KpiInitView
    }

    @IBOutlet private var undoneView: UIView!
    @IBOutlet private var undondeText: MYTextField!
    @IBOutlet private var okButton: MYButton!
    @IBOutlet private var noButton: MYButton!
    @IBOutlet private var datePicker: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
        for btn in [okButton, noButton] {
            btn?.layer.cornerRadius = (btn?.frame.size.height)! / 2
        }
        firstLoad()
        okTapped()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        undondeText.text = MYJob.shared.jobResult.comment
        if MYJob.shared.jobResult.execution_date.isEmpty == false {
            let d = MYJob.shared.jobResult.execution_date + " " + MYJob.shared.jobResult.execution_start_time + ":00"
            let date = d.toDate(withFormat: Config.DateFmt.DataOraJson)
            datePicker.date = date
        }
    }
    
    override func checkData() -> KpiResultType {
        if undoneView.isHidden == false && (undondeText.text?.isEmpty)! {
            undondeText.becomeFirstResponder()
            return .errNotes
        }
        
        MYJob.shared.jobResult.execution_date = datePicker.date.toString(withFormat: Config.DateFmt.DataJson)
        MYJob.shared.jobResult.execution_start_time = datePicker.date.toString(withFormat: Config.DateFmt.Ora)
        MYResult.shared.saveResult()
        return .next
    }
    
    // MARK: - Actions
    
    @IBAction func okTapped () {
        undoneView.isHidden = true
        okButton.backgroundColor = UIColor.white
        noButton.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func noTapped () {
        undoneView.isHidden = false
        okButton.backgroundColor = UIColor.lightGray
        noButton.backgroundColor = UIColor.white
    }
    
    private func firstLoad () {
        let path = "\(Config.Path.doc)/\(MYJob.shared.job.id)"
        let fm = FileManager.default
        if fm.fileExists(atPath: path) == false {
            do {
                try fm.createDirectory(atPath: path,
                                       withIntermediateDirectories: true,
                                       attributes: nil)
            } catch let error as NSError {
                print("Unable to create directory \(error.debugDescription)")
            }
        }
        
        if MYJob.shared.jobResult.results.count < MYJob.shared.job.kpis.count {
            for _ in MYJob.shared.jobResult.results.count...MYJob.shared.job.kpis.count - 1 {
                MYJob.shared.jobResult.results.append(JobResult.KpiResult())
            }
            MYResult.shared.saveResult()
        }
    }
}

