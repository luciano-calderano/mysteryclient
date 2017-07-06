//
//  SubPage.swift
//  MysteryClient
//
//  Created by mac on 06/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit


// MARK: -


//class SubPage: SubKpi {
//    var kpi: Job.Kpi!
//    var kpiResult: JobResult.KpiResult!
//    
//    private var idx = 0
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.idx = (self.navigationController?.viewControllers.count)! - 2
//        if idx < 0 {
//            return
//        }
//        if idx >= Config.jobResult.results.count {
//            Config.jobResult.results.append(JobResult.KpiResult())
//        }
//        self.kpi = Config.job.kpis[idx]
////
//        let counter = (self.navigationController?.viewControllers.count)!
//        if counter > 1 {
//            self.kpiResult = Config.jobResult.results[self.idx]
//        }
//    }
//}

class SubPage: KpiSubView, UITextViewDelegate {
    class func Instance() -> SubPage {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubPage
    }
    
    @IBOutlet private var subView: UIView!
    @IBOutlet private var subViewHeight: NSLayoutConstraint!
    @IBOutlet private var kpiTitle: MYLabel!
    @IBOutlet private var kpiQuestion: MYLabel!
    @IBOutlet private var kpiNote: UITextView!
    @IBOutlet private var kpiAtchBtn: MYButton!
    
    private var attachmentPath = ""
    private var indexSelected = 0
    
    private var kpiSubView: KpiSubView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.kpiNote.text = ""
        self.kpiNote.delegate = self
        self.kpiNote.layer.borderColor = UIColor.lightGray.cgColor
        self.kpiNote.layer.borderWidth = 1
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            return
        }

        
        self.subViewHeight.constant = 0
        
        switch kpi.type {
        case "radio" :
            self.kpiSubView = SubRadio.Instance()
            self.subView.addSubviewWithConstraints(self.kpiSubView)
        default:
            return
        }
        //    }
        //
        //    override func viewWillAppear(_ animated: Bool) {
        //        super.viewWillAppear(animated)
        self.subViewHeight.constant = self.kpiSubView.data(valuations: self.kpi.valuations,                                             kpiResult: self.kpiResult)
        //        self.view.layoutSubviews()
        self.kpiAtchBtn.isHidden = !self.kpi.attachment
        
        self.indexSelected = 0
        self.kpiNote.text = self.kpiResult.notes
        if self.kpiResult.value.isEmpty == false {
            let index = Int(self.kpiResult.value)
            for item in self.kpi.valuations {
                if item.id == index {
                    break
                }
                self.indexSelected += 1
            }
        }
        
        self.kpiTitle.text = self.kpi.factor
        self.kpiQuestion.text = self.kpi.standard

    }
    

    
    override func checkData() -> KpiResultType {
        if self.kpi.attachment_required == true {
            if self.attachmentPath.isEmpty {
                return .err
            }
        }
        if self.kpi.note_required == true {
            if self.kpiNote.text.isEmpty {
                return .err
            }
        }
        
        let item = self.kpi.valuations[self.indexSelected]
        self.kpiResult.kpi_id = self.kpi.id
        self.kpiResult.value = String(item.id)
        self.kpiResult.notes = self.kpiNote.text
        Config.jobResult.save()
        self.endEditing(true)
        return .next
    }
    
    //MARK: - text view delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        self.delegate?.startEditing(y: self.kpiNote.frame.origin.y - 30)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
//            self.delegate?.endEditing()
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
