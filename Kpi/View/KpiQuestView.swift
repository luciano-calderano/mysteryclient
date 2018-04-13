//
//  SubKpi.swift
//  MysteryClient
//
//  Created by Lc on 11/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//
import UIKit

class KpiQuestView: KpiBaseView {
    class func Instance() -> KpiQuestView {
        let id = "KpiQuestView"
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! KpiQuestView
    }
    
    @IBOutlet private var content: UIView!
//    @IBOutlet private var contentH: NSLayoutConstraint!
    
    @IBOutlet private var atchView: UIView!
    @IBOutlet private var atchName: MYLabel!
    @IBOutlet private var atchImage: UIImageView!
    
    @IBOutlet private var subView: UIView!
    @IBOutlet private var bottomLine: UIView!
    
    @IBOutlet private var kpiTitle: MYLabel!
    @IBOutlet private var kpiQuestion: MYLabel!
    @IBOutlet private var kpiInstructions: MYLabel!
    @IBOutlet private var kpiAtchBtn: MYButton!
    
    @IBOutlet private var subViewHeight: NSLayoutConstraint!
    
    @IBOutlet var kpiNote: UITextView!
    
    private var valueMandatoty = true
    private var kpiQuestSubView: KpiBaseSubView!
    private let kpiQuestPath = Config.Path.doc + String(MYJob.shared.job.id) + "/"
    private var kpiAtch: KpiAtch?
    
    //MARK:-
    
    override func awakeFromNib() {
        super.awakeFromNib()
        kpiNote.delegate = self
        kpiNote.layer.borderWidth = 1
        kpiNote.layer.borderColor = UIColor.lightGray.cgColor
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(atchRemove))
        atchView.addGestureRecognizer(tap)
        atchView.isUserInteractionEnabled = true
        atchView.layer.borderColor = UIColor.lightGray.cgColor
        atchView.layer.borderWidth = 1
    }
    
    override func initialize() {
        super.initialize()
        kpiTitle.text = currentKpi.factor
        kpiQuestion.text = currentKpi.standard
        kpiInstructions.text = currentKpi.instructions
        kpiAtchBtn.isHidden = !currentKpi.attachment && !currentKpi.attachment_required
        
        kpiNote.text = kpiResult.notes
        showAtch()
        
        addQuestSubview(type: currentKpi.type)
    }
    
    override func checkData(completion: @escaping (KpiResultType) -> ()) {
        var noteRequired = currentKpi.note_required
        var atchRequired = currentKpi.attachment_required
        let responseValue = kpiQuestSubView.getValuation()
        
        if currentKpi.required == true {
            if responseValue.value.isEmpty && valueMandatoty == true {
                completion (.errValue)
            }
            if responseValue.notesReq == true {
                noteRequired = responseValue.notesReq
            }
            if responseValue.attchReq == true {
                atchRequired = responseValue.attchReq
            }
        }
        
        if noteRequired == true && kpiNote.text.isEmpty {
            completion (.errNotes)
        }
        
        if atchRequired == true && atchImage.image == nil {
            askNoAtch { (result) in
                if result  {
                    saveResult()
                    completion (.next)
                } else {
                    completion (.errAttch)

                }
            }
        }
        func saveResult () {
            let kpiResult = MYJob.shared.jobResult.results[kpiIndex]
            let originaValue = kpiResult.value
            kpiResult.kpi_id = currentKpi.id
            kpiResult.value = responseValue.value
            kpiResult.notes = kpiNote.text
            kpiResult.attachment = atchName.text!
            MYJob.shared.jobResult.results[kpiIndex] = kpiResult
            
            if responseValue.valuations != nil {
                let qDep = QuestDependency(withResponse: responseValue)
                qDep.update(withReset: originaValue != responseValue.value)
            }
            
            MYResult.shared.saveResult()
            
            self.endEditing(true)
        }
        saveResult()
        completion (.next)
    }
    
    func showAtch () {
        atchImage.image = nil
        if kpiResult.attachment.isEmpty == false {
            let fileName = kpiQuestPath + kpiResult.attachment
            let imageURL = URL(fileURLWithPath: fileName)
            atchImage.image = UIImage(contentsOfFile: imageURL.path)
        }
        
        if atchImage.image == nil {
            atchView.isHidden = true
            kpiResult.attachment = ""
        } else {
            atchView.isHidden = false
        }
        atchName.text = kpiResult.attachment
        MYJob.shared.jobResult.results[kpiIndex] = kpiResult
    }
    
    @objc func atchRemove () {
        let fileName = kpiQuestPath + kpiResult.attachment
        mainVC.alert(MYLng("atchRemove"), message: "", cancelBlock: nil) {
            (remove) in
            do {
                try FileManager.default.removeItem(atPath: fileName)
            }
            catch let error as NSError {
                print("removeItem atPath: \(error)")
            }
            self.showAtch()
        }
    }
    
    //MARK: - Actions
    
    @IBAction func atchButtonTapped () {
        if kpiAtch == nil {
            kpiAtch = KpiAtch.init(mainViewCtrl: mainVC)
            kpiAtch?.delegate = self
        }
        kpiAtch?.showArchSelection()
    }
    
    private func askNoAtch (completion: @escaping (Bool) -> ()) {
        let alert = UIAlertController(title: MYLng("noAtchTitle"),
                                      message:MYLng("noAtchMsg"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: MYLng("no"),
                                           style: .default,
                                           handler: { (action) in
                                            completion(false)
        }))
        
        alert.addAction(UIAlertAction.init(title: MYLng("yes"),
                                           style: .default,
                                           handler: { (action) in
                                            completion(true)
        }))
        
        mainVC.present(alert, animated: true) { }

    }
    
    //MARK: - Private
    
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
            kpiQuestSubView = KpiBaseSubView()
            valueMandatoty = false
        }
        subView.addSubviewWithConstraints(kpiQuestSubView)
        kpiQuestSubView.delegate = self
        kpiQuestSubView.currentKpi = currentKpi
        kpiQuestSubView.kpiResult = kpiResult
    }
}

//MARK: - page subview delegate

extension KpiQuestView: KpiDelegate {
    func kpiViewHeight(_ height: CGFloat) {
        subViewHeight.constant = height
        var rect = self.frame
        rect.size.height += height
        self.frame = rect
    }
}

//MARK: - text view delegate

extension KpiQuestView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.kpiStartEditingAtPosY(kpiNote.frame.origin.y - 30)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.kpiEndEditing()
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK:- Image picker

extension KpiQuestView: KpiAtchDelegate {
    func kpiAtchSelectedImage(_ image: UIImage) {
        kpiResult.attachment = "\(MYJob.shared.job.reference).\(currentKpi.id).jpg"
        let fileName = kpiQuestPath + kpiResult.attachment
        
        do {
            if let data = UIImageJPEGRepresentation(image, 0.7) {
                try data.write(to: URL.init(string: "file://" + fileName)!)
            }
        } catch {
        }
        showAtch()
    }
}

