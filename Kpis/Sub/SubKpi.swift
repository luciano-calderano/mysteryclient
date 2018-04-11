//
//  SubKpi.swift
//  MysteryClient
//
//  Created by Lc on 11/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//
import UIKit

class SubKpi: KpisSubView {
    class func Instance() -> SubKpi {
        let id = "SubKpi"
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubKpi
    }

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
    
    @IBOutlet var subViewHeight: NSLayoutConstraint!
    
    @IBOutlet private var hasAttch: UIImageView!
    @IBOutlet private var hasNotes: UIImageView!
    
    @IBOutlet var kpiNote: UITextView!
    
    var valueMandatoty = true
    var attachmentImage: UIImage? {
        didSet { showAtch() }
    }
    
    private var kpiQuestSubView: KpiQuestSubView!
    private let kpiQuestPath = Config.Path.doc + String(MYJob.shared.job.id) + "/"
    private var fileName = ""
    
    //MARK:-
    
    override func awakeFromNib() {
        super.awakeFromNib()
        kpiNote.delegate = self
        kpiNote.layer.borderWidth = 1
        kpiNote.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func initialize() {
        super.initialize()
        kpiTitle.text = currentKpi.factor
        kpiQuestion.text = currentKpi.standard
        kpiInstructions.text = currentKpi.instructions
        kpiAtchBtn.isHidden = !currentKpi.attachment && !currentKpi.attachment_required
        
        hasNotes.isHidden = !currentKpi.note_required
        hasAttch.isHidden = !currentKpi.attachment_required
        
        updateFromResultAtIndex(kpiIndex)
        addQuestSubview(type: currentKpi.type)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(atchRemove))
        atchView.addGestureRecognizer(tap)
        atchView.isUserInteractionEnabled = true
        atchView.layer.borderColor = UIColor.lightGray.cgColor
        atchView.layer.borderWidth = 1
    }
    
    override func checkData() -> KpiMain.ResultType {
        var noteRequired = currentKpi.note_required
        var atchRequired = currentKpi.attachment_required
        let result = kpiQuestSubView.getValuation()
        
        if currentKpi.required == true {
            if result.value.isEmpty && valueMandatoty == true {
                return .errValue
            }
            if result.notesReq == true {
                noteRequired = result.notesReq
            }
            if result.attchReq == true {
                atchRequired = result.attchReq
            }
        }
        
        if noteRequired == true && kpiNote.text.isEmpty {
            return .errNotes
        }
        
        if atchRequired == true && atchImage.image == nil {
            return .errAttch
        }
        
        let kpiResult = MYJob.shared.jobResult.results[kpiIndex]
        let originaValue = kpiResult.value
        kpiResult.kpi_id = currentKpi.id
        kpiResult.value = result.value
        kpiResult.notes = kpiNote.text
        kpiResult.attachment = atchName.text!
        MYJob.shared.jobResult.results[kpiIndex] = kpiResult
        
        if result.valuations != nil {
            let qDep = QuestDependency(withResult: result)
            qDep.update(withReset: originaValue != result.value)
        }
        
        MYResult.shared.saveResult()
        
        self.endEditing(true)
        return .next
    }
    
    func showAtch () {
        let kpiResult = MYJob.shared.jobResult.results[kpiIndex]
        if attachmentImage == nil {
            atchView.isHidden = true
            kpiResult.attachment = ""
        }
        else {
            let kpiQuest = MYJob.shared.job.kpis[kpiIndex]
            
            atchView.isHidden = false
            atchImage.image = attachmentImage
            if kpiResult.attachment.isEmpty {
                kpiResult.attachment = "\(MYJob.shared.job.reference).\(kpiQuest.id).jpg"
                fileName = kpiQuestPath + kpiResult.attachment
                
                if let data = UIImageJPEGRepresentation(attachmentImage!, 0.7) {
                    try? data.write(to: URL.init(string: fileName)!)
                }
            }
        }
        atchName.text = kpiResult.attachment
        MYJob.shared.jobResult.results[kpiIndex] = kpiResult
    }
    
    @objc func atchRemove () {
//        alert(MYLng("atchRemove"), message: "", cancelBlock: nil) {
//            (remove) in
//            do {
//                try FileManager.default.removeItem(atPath: self.fileName)
//            }
//            catch let error as NSError {
//                print("removeItem atPath: \(error)")
//            }
//            self.attachmentImage = nil
//            self.showAtch()
//        }
    }
    
    //MARK: - Actions
    
    @IBAction func atchButtonTapped () {
//        delegate?.atchButtonTapped()
    }
    
    //MARK: - Private
    
    private func updateFromResultAtIndex(_ index: Int) {
        let kpiResult = MYJob.shared.jobResult.results[kpiIndex]
        kpiNote.text = kpiResult.notes
        if kpiResult.attachment.isEmpty == false {
            fileName = kpiQuestPath + kpiResult.attachment
            let imageURL = URL(fileURLWithPath: fileName)
            let image    = UIImage(contentsOfFile: imageURL.path)
            attachmentImage = image
        }
        showAtch()
    }
    
    private func addQuestSubview (type: String) {
        valueMandatoty = true
        subViewHeight.constant = 1
        switch type {
        case "radio", "select" :
            kpiQuestSubView = SubRadio.Instance()
        case "text" :
            kpiQuestSubView = SubText.Instance()
        case "date" :
            kpiQuestSubView = SubDatePicker.Instance(type: .date)
        case "time" :
            kpiQuestSubView = SubDatePicker.Instance(type: .time)
        case "datetime" :
            kpiQuestSubView = SubDatePicker.Instance(type: .datetime)
        case "label", "geophoto" :
            kpiQuestSubView = SubLabel.Instance()
            valueMandatoty = false
        case "multicheckbox" :
            kpiQuestSubView = SubCheckBox.Instance()
        default:
            valueMandatoty = false
            kpiQuestSubView = KpiQuestSubView()
        }
        subView.addSubviewWithConstraints(kpiQuestSubView)
        kpiQuestSubView.delegate = self
        kpiQuestSubView.initialize(kpiIndex: kpiIndex)
    }
    
    class QuestDependency {
        var result: KpiResponseValues!
        init(withResult r: KpiResponseValues) {
            result = r
        }
        
        func update (withReset: Bool) {
            if withReset {
                for val in result.valuations! {
                    updateInvalidKpiWithDep(val, isReset: true)
                }
                print("reset \(MYJob.shared.invalidDependecies)")
            }
            for val in result.valuations! {
                if val.id == Int(result.value) {
                    updateInvalidKpiWithDep(val, isReset: false)
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

extension SubKpi: KpiQuestSubViewDelegate {
    func kpiQuestSubViewNewHeight (_ newHeight: CGFloat) {
        subViewHeight.constant = newHeight
        var rect = self.frame
        rect.size.height += newHeight
        self.frame = rect
//        subKpiDelegate?.subKpiNewHeigth(height: self.frame.size.height)
    }
}

//MARK: - text view delegate
extension SubKpi: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
//        delegate?.startEditing(scroll: scroll, y: kpiNote.frame.origin.y - 30)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            delegate?.endEditing()
//            textView.resignFirstResponder()
//            return false
//        }
        return true
    }
}
