//
//  KpiQuest.swift
//  MysteryClient
//
//  Created by mac on 10/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiQuest: KpiQuestViewController, KpiSubViewDelegate, UITextViewDelegate {
    override class func Instance() -> KpiQuest {
        let vc = self.load(storyboardName: "Kpi") as! KpiQuest
        return vc
    }

    @IBOutlet private var subView: UIView!
    @IBOutlet private var subViewHeight: NSLayoutConstraint!
    @IBOutlet private var bottomLine: UIView!
    
    @IBOutlet private var kpiTitle: MYLabel!
    @IBOutlet private var kpiQuestion: MYLabel!
    @IBOutlet private var kpiInstructions: MYLabel!
    @IBOutlet private var kpiNote: UITextView!
    @IBOutlet private var kpiAtchBtn: MYButton!
    
    private var attachmentPath = ""
    private var kpiPageSubView: KpiPageSubView!
    private var initialContentH:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialContentH = self.contentH.constant
        
        let idx = (self.navigationController?.viewControllers.count)! - 1
        self.kpi = Config.job.kpis[idx]
        self.kpiResult = Config.jobResult.results[idx]

        self.kpiNote.delegate = self
        self.kpiNote.layer.borderColor = UIColor.lightGray.cgColor
        self.kpiNote.layer.borderWidth = 1
        
        self.kpiTitle.text = self.kpi.factor
        self.kpiQuestion.text = self.kpi.standard
        self.kpiInstructions.text = self.kpi.instructions
        self.kpiNote.text = self.kpiResult.notes
        self.kpiAtchBtn.isHidden = !self.kpi.attachment

        self.subViewHeight.constant = 1
        switch self.kpi.type {
        case "radio" :
            self.kpiPageSubView = SubRadio.Instance()
        case "text" :
            self.kpiPageSubView = SubText.Instance()
        default:
            self.kpiPageSubView = KpiPageSubView()
        }
        self.subView.addSubviewWithConstraints(self.kpiPageSubView)
        
        self.kpiPageSubView.delegate = self
        self.kpiPageSubView.initialize(kpiResult: self.kpiResult,
                                       valuations: self.kpi.valuations)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.contentH.constant =  max(self.bottomLine.frame.origin.y + 2, self.scroll.frame.size.height)
        self.scroll.contentSize = self.content.frame.size
    }
    
    override func checkData() -> KpiResultType {
        var noteRequired = self.kpi.note_required
        var atchRequired = self.kpi.attachment_required
        let val = self.kpiPageSubView.valuationSelected
        
        if self.kpi.required == true {
            if self.kpi.valuations.count > 0 && val == nil {
                return .errValue
            }
            
            if val == nil {
                self.kpiResult.value = self.kpiPageSubView.value
            }
            else {
                self.kpiResult.value = String((val?.id)!)
                noteRequired = (val?.note_required)!
                atchRequired = (val?.attachment_required)!
            }
            if self.kpiResult.value.isEmpty {
                return .errValue
            }
        }
        
        if noteRequired == true && self.kpiNote.text.isEmpty {
            return .errNotes
        }
        
        if atchRequired == true && self.attachmentPath.isEmpty {
            return .errAttch
        }
        
        self.kpiResult.kpi_id = self.kpi.id
        self.kpiResult.notes = self.kpiNote.text
        Config.jobResult.save()
        
        self.view.endEditing(true)
        return .next
    }
    
    //MARK: - Actions
    
    @IBAction func atchButtonTapped () {
        self.delegate?.atchButtonTapped(page: self.view as! KpiPageQuest)
    }
    
    //MARK: - page subview delegate
    
    func subViewResized (newHeight: CGFloat) {
        self.subViewHeight.constant = newHeight
    }
    
    //MARK: - text view delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.startEditing(y: self.kpiNote.frame.origin.y - 30)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.delegate?.endEditing()
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
