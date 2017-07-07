//
//  KpiPageQuest.swift
//  MysteryClient
//
//  Created by mac on 06/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiPageQuest: KpiPageView, KpiSubViewDelegate, UITextViewDelegate {
    class func Instance() -> KpiPageQuest {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! KpiPageQuest
    }
    
    @IBOutlet private var subView: UIView!
    @IBOutlet private var subViewHeight: NSLayoutConstraint!
    @IBOutlet private var kpiTitle: MYLabel!
    @IBOutlet private var kpiQuestion: MYLabel!
    @IBOutlet private var kpiInstructions: MYLabel!
    @IBOutlet private var kpiNote: UITextView!
    @IBOutlet private var kpiAtchBtn: MYButton!
    
    private var attachmentPath = ""    
    private var kpiPageSubView: KpiPageSubView!
    
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
            self.kpiPageSubView = SubRadio.Instance()
            self.kpiPageSubView.delegate = self
            self.subView.addSubviewWithConstraints(self.kpiPageSubView)
        default:
            self.kpiPageSubView = KpiPageSubView()
            self.kpiPageSubView.delegate = self
            self.subView.addSubviewWithConstraints(self.kpiPageSubView)
        }
        
        self.kpiPageSubView.initialize(kpiResult: self.kpiResult,
                                       valuations: self.kpi.valuations)
        self.kpiTitle.text = self.kpi.factor
        self.kpiQuestion.text = self.kpi.standard
        self.kpiInstructions.text = self.kpi.instructions
        self.kpiNote.text = self.kpiResult.notes
        self.kpiAtchBtn.isHidden = !self.kpi.attachment
    }
    
    override func checkData() -> KpiResultType {
        let val = self.kpiPageSubView.valuationSelected
        var noteRequired = self.kpi.note_required
        var atchRequired = self.kpi.attachment_required
        
        if self.kpi.required == true && val == nil {
            return .errValue
        }
        if val == nil {
            self.kpiResult.value = ""
        }
        else {
            self.kpiResult.value = String((val?.id)!)
            noteRequired = (val?.note_required)!
            atchRequired = (val?.attachment_required)!
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
        
        self.endEditing(true)
        return .next
    }

    //MARK: - Actions 
    
    @IBAction func atchButtonTapped () {
        self.delegate?.atchButtonTapped(page: self)
    }

    //MARK: - page subview delegate
    
    func subViewResized (newHeight: CGFloat) {
        self.subViewHeight.constant = newHeight
        var rect = self.frame
        rect.size.height += newHeight
        self.frame = rect
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
