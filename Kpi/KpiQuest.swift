//
//  KpiQuest.swift
//  MysteryClient
//
//  Created by mac on 10/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiQuest: KpiViewController {
    @IBOutlet private var content: UIView!
    @IBOutlet private var contentH: NSLayoutConstraint!
    
    @IBOutlet private var atchView: UIView!
    @IBOutlet private var atchName: MYLabel!
    @IBOutlet private var atchImage: UIImageView!
    
    @IBOutlet private var subView: UIView!
    @IBOutlet private var bottomLine: UIView!
    
    @IBOutlet private var kpiTitle: MYLabel!
    @IBOutlet private var kpiQuestion: MYLabel!
    @IBOutlet private var kpiInstructions: MYLabel!
    @IBOutlet private var kpiAtchBtn: MYButton!
    
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var subViewHeight: NSLayoutConstraint!
    
    @IBOutlet private var hasAttch: UIImageView!
    @IBOutlet private var hasNotes: UIImageView!
    
    @IBOutlet var kpiNote: UITextView!
    
    var valueMandatoty = true
    var attachmentImage: UIImage? {
        didSet { self.showAtch() }
    }
    
    private var kpiQuestSubView: KpiQuestSubView!
    private let kpiQuestPath = Config.doc + String(MYJob.shared.job.id) + "/"
    private var fileName = ""
    
    //MARK:-
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let kpiQuest = MYJob.shared.job.kpis[self.kpiIndex]
        
        self.kpiNote.delegate = self
        self.kpiNote.layer.borderWidth = 1
        self.kpiNote.layer.borderColor = UIColor.lightGray.cgColor
        self.kpiTitle.text = kpiQuest.factor
        self.kpiQuestion.text = kpiQuest.standard
        self.kpiInstructions.text = kpiQuest.instructions
        self.kpiAtchBtn.isHidden = !kpiQuest.attachment && !kpiQuest.attachment_required
        
        self.hasNotes.isHidden = !kpiQuest.note_required
        self.hasAttch.isHidden = !kpiQuest.attachment_required
        
        self.updateFromResultAtIndex(self.kpiIndex)
        self.addQuestSubview(type: kpiQuest.type)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.atchRemove))
        self.atchView.addGestureRecognizer(tap)
        self.atchView.isUserInteractionEnabled = true
        self.atchView.layer.borderColor = UIColor.lightGray.cgColor
        self.atchView.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scroll.contentOffset = CGPoint.zero
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.contentH.constant =  max(self.bottomLine.frame.origin.y + 2, self.scroll.frame.size.height)
        self.scroll.contentSize = self.content.frame.size
    }
    
    override func checkData() -> KpiResultType {
        let kpiQuest = MYJob.shared.job.kpis[self.kpiIndex]
        
        var noteRequired = kpiQuest.note_required
        var atchRequired = kpiQuest.attachment_required
        let result = self.kpiQuestSubView.getValuation()
        
        if kpiQuest.required == true {
            if result.value.isEmpty && self.valueMandatoty == true {
                return .errValue
            }
            if result.notesReq == true {
                noteRequired = result.notesReq
            }
            if result.attchReq == true {
                atchRequired = result.attchReq
            }
        }
        
        if noteRequired == true && self.kpiNote.text.isEmpty {
            return .errNotes
        }
        
        if atchRequired == true && self.atchImage.image == nil {
            return .errAttch
        }
        
        let kpiResult = MYJob.shared.jobResult.results[self.kpiIndex]
        let originaValue = kpiResult.value
        kpiResult.kpi_id = kpiQuest.id
        kpiResult.value = result.value
        kpiResult.notes = self.kpiNote.text
        kpiResult.attachment = self.atchName.text!
        MYJob.shared.jobResult.results[self.kpiIndex] = kpiResult
        
        if result.valuations != nil {
            let qDep = QuestDependency(withResult: result)
            qDep.update(withReset: originaValue != result.value)
        }
        
        MYResult.shared.saveResult()
        
        self.view.endEditing(true)
        return .next
    }

    func showAtch () {
        let kpiResult = MYJob.shared.jobResult.results[self.kpiIndex]
        if self.attachmentImage == nil {
            self.atchView.isHidden = true
            kpiResult.attachment = ""
        }
        else {
            let kpiQuest = MYJob.shared.job.kpis[self.kpiIndex]
            
            self.atchView.isHidden = false
            self.atchImage.image = self.attachmentImage
            if kpiResult.attachment.isEmpty {
                kpiResult.attachment = "\(MYJob.shared.job.reference).\(kpiQuest.id).jpg"
                self.fileName = self.kpiQuestPath + kpiResult.attachment
                
                if let data = UIImageJPEGRepresentation(self.attachmentImage!, 0.7) {
                    try? data.write(to: URL.init(string: self.fileName)!)
                }
            }
        }
        self.atchName.text = kpiResult.attachment
        MYJob.shared.jobResult.results[self.kpiIndex] = kpiResult
    }
    
    func atchRemove () {
        self.alert(Lng("atchRemove"), message: "", cancelBlock: nil) {
            (remove) in
            do {
                try FileManager.default.removeItem(atPath: self.fileName)
            }
            catch let error as NSError {
                print("removeItem atPath: \(error)")
            }
            self.attachmentImage = nil
            self.showAtch()
        }
    }
    
    //MARK: - Actions
    
    @IBAction func atchButtonTapped () {
        self.delegate?.atchButtonTapped()
    }
    
    //MARK: - Private
    
    private func updateFromResultAtIndex(_ index: Int) {
        let kpiResult = MYJob.shared.jobResult.results[self.kpiIndex]
        self.kpiNote.text = kpiResult.notes
        if kpiResult.attachment.isEmpty == false {
            self.fileName = self.kpiQuestPath + kpiResult.attachment
            let imageURL = URL(fileURLWithPath: self.fileName)
            let image    = UIImage(contentsOfFile: imageURL.path)
            self.attachmentImage = image
        }
        self.showAtch()
    }
    
    private func addQuestSubview (type: String) {
        self.valueMandatoty = true
        self.subViewHeight.constant = 1
        switch type {
        case "radio", "select" :
            self.kpiQuestSubView = SubRadio.Instance()
        case "text" :
            self.kpiQuestSubView = SubText.Instance()
        case "date" :
            self.kpiQuestSubView = SubDatePicker.Instance(type: .date)
        case "time" :
            self.kpiQuestSubView = SubDatePicker.Instance(type: .time)
        case "datetime" :
            self.kpiQuestSubView = SubDatePicker.Instance(type: .datetime)
        case "label", "geophoto" :
            self.kpiQuestSubView = SubLabel.Instance()
            self.valueMandatoty = false
        case "multicheckbox" :
            self.kpiQuestSubView = SubCheckBox.Instance()
        default:
            self.valueMandatoty = false
            self.kpiQuestSubView = KpiQuestSubView()
        }
        self.subView.addSubviewWithConstraints(self.kpiQuestSubView)
        self.kpiQuestSubView.delegate = self
        self.kpiQuestSubView.initialize(kpiIndex: self.kpiIndex)
    }
    
    class QuestDependency {
        var result: KpiResponseValues!
        init(withResult result: KpiResponseValues) {
            self.result = result
        }
        
        func update (withReset: Bool) {
            if withReset {
                for val in result.valuations! {
                    self.updateInvalidKpiWithDep(val, isReset: true)
                }
                print("reset \(MYJob.shared.invalidDependecies)")
            }
            for val in result.valuations! {
                if val.id == Int(result.value) {
                    self.updateInvalidKpiWithDep(val, isReset: false)
                }
            }
            print("fix \(MYJob.shared.invalidDependecies)")
        }
        
        private func updateInvalidKpiWithDep (_ val: Job.Kpi.Valuation, isReset: Bool) {
            for dep in val.dependencies {
                let idIndex = MYJob.shared.kpiKeyList.index(of: dep.key)
                if idIndex == nil {
                    return
                }
                let index = idIndex!
                
                let kpiResult = MYJob.shared.jobResult.results[index]
                kpiResult.kpi_id = dep.key
                if isReset {
                    kpiResult.value = ""
                    kpiResult.notes = ""
                    
                } else {
                    kpiResult.value = dep.value
                    kpiResult.notes = dep.notes
                }
                MYJob.shared.jobResult.results[index] = kpiResult
                
                let idx = MYJob.shared.invalidDependecies.index(of: String(dep.key))
                if isReset {
                    if (idx != nil) {
                        MYJob.shared.invalidDependecies.remove(at: idx!)
                    }
                } else {
                    if (idx == nil) {
                        MYJob.shared.invalidDependecies.append(String(dep.key))
                    }
                }
            }
        }
    }
}


//MARK: - page subview delegate
extension KpiQuest: KpiQuestSubViewDelegate {
    func kpiQuestSubViewNewHeight (_ newHeight: CGFloat) {
        self.subViewHeight.constant = newHeight
    }
}

//MARK: - text view delegate
extension KpiQuest: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.startEditing(scroll: self.scroll, y: self.kpiNote.frame.origin.y - 30)
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
