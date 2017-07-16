//
//  KpiQuest.swift
//  MysteryClient
//
//  Created by mac on 10/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiQuest: KpiViewController, KpiQuestSubViewDelegate, UITextViewDelegate {
    class func Instance(index: Int) -> KpiQuest {
        let vc = self.load(storyboardName: "Kpi") as! KpiQuest
        vc.index = index
        return vc
    }

    @IBOutlet private var scroll: UIScrollView!
    @IBOutlet private var content: UIView!
    @IBOutlet private var contentH: NSLayoutConstraint!
    
    @IBOutlet private var atchView: UIView!
    @IBOutlet private var atchName: MYLabel!
    @IBOutlet private var atchImage: UIImageView!
    
    @IBOutlet private var subView: UIView!
    @IBOutlet private var subViewHeight: NSLayoutConstraint!
    @IBOutlet private var bottomLine: UIView!
    
    @IBOutlet private var kpiTitle: MYLabel!
    @IBOutlet private var kpiQuestion: MYLabel!
    @IBOutlet private var kpiInstructions: MYLabel!
    @IBOutlet private var kpiNote: UITextView!
    @IBOutlet private var kpiAtchBtn: MYButton!
    
    var index = 0
    var attachmentImage: UIImage? {
        didSet { self.showAtch() }
    }
    
    private var kpi: Job.Kpi!
    private var kpiResult: JobResult.KpiResult!
    private var kpiQuestSubView: KpiQuestSubView!
    
    private let path = NSTemporaryDirectory() + String(MYJob.shared.job.id) + "/"
    private var fileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.kpi = MYJob.shared.job.kpis[self.index]
        self.kpiResult = MYJob.shared.jobResult.results[self.index]

        self.kpiNote.delegate = self
        self.kpiNote.layer.borderColor = UIColor.lightGray.cgColor
        self.kpiNote.layer.borderWidth = 1
        
        self.kpiTitle.text = self.kpi.factor
        self.kpiQuestion.text = self.kpi.standard
        self.kpiInstructions.text = self.kpi.instructions
        self.kpiNote.text = self.kpiResult.notes
        self.kpiNote.layer.borderColor = (self.kpi.note_required ? UIColor.red : UIColor.myGreenDark).cgColor
        self.kpiNote.layer.borderWidth = 1
        
        self.kpiAtchBtn.isHidden = !self.kpi.attachment && !self.kpi.attachment_required
        if self.kpiResult.attachment.isEmpty == false {
            self.fileName = self.path + self.kpiResult.attachment
            let imageURL = URL(fileURLWithPath: self.fileName)
            let image    = UIImage(contentsOfFile: imageURL.path)
            self.attachmentImage = image
        }
        self.showAtch()
        
        self.subViewHeight.constant = 1
        switch self.kpi.type {
        case "radio", "select" :
            self.kpiQuestSubView = SubRadio.Instance()
        case "text" :
            self.kpiQuestSubView = SubText.Instance()
        case "date" :
            self.kpiQuestSubView = SubDatePicker.Instance(type: .date)
            break
        case "time" :
            self.kpiQuestSubView = SubDatePicker.Instance(type: .time)
            break
        case "datetime" :
            self.kpiQuestSubView = SubDatePicker.Instance(type: .datetime)
            break
        case "label", "geophoto" :
            alert("kpi.type: \(self.kpi.type)", message: "", okBlock: nil)
            break
        case "multicheckbox" :
            self.kpiQuestSubView = SubCheckBox.Instance()
            break
        default:
            self.kpiQuestSubView = KpiQuestSubView()
        }
        self.subView.addSubviewWithConstraints(self.kpiQuestSubView)
        
        self.kpiQuestSubView.delegate = self
        self.kpiQuestSubView.initialize(kpiResult: self.kpiResult,
                                       valuations: self.kpi.valuations)
        
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
        var noteRequired = self.kpi.note_required
        var atchRequired = self.kpi.attachment_required
        let result = self.kpiQuestSubView.getValuation()
        
        if self.kpi.required == true {
            if result.value.isEmpty && kpi.type.isEmpty == false {
                return .errValue
            }
            self.kpiResult.value = result.value
            if result.notes == true {
                noteRequired = result.notes
            }
            if result.attch == true {
                atchRequired = result.attch
            }
        }
        
        if noteRequired == true && self.kpiNote.text.isEmpty {
            return .errNotes
        }
        
        if atchRequired == true && self.atchImage == nil {
            return .errAttch
        }
        
        self.kpiResult.kpi_id = self.kpi.id
        self.kpiResult.notes = self.kpiNote.text
        MYJob.shared.saveResult()
        
        self.view.endEditing(true)
        return .next
    }
    
    func showAtch () {
        if self.attachmentImage == nil {
            self.atchView.isHidden = true
            self.kpiResult.attachment = ""
        }
        else {
            self.atchView.isHidden = false
            self.atchImage.image = self.attachmentImage
            if self.kpiResult.attachment.isEmpty {
                self.kpiResult.attachment = String(MYJob.shared.job.reference) + "." + String(self.kpi.id) + ".jpg"
                self.fileName = self.path + self.kpiResult.attachment
                
                if let data = UIImageJPEGRepresentation(self.attachmentImage!, 0.7) {
                    try? data.write(to: URL.init(string: self.fileName)!)
                }
            }
        }
        self.atchName.text = self.kpiResult.attachment
    }
    
    func atchRemove () {
        self.alert(Lng("atchRemove"), message: "",
                   cancelBlock: nil) { (remove) in
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
    
    //MARK: - page subview delegate
    
    func subViewResized (newHeight: CGFloat) {
        self.subViewHeight.constant = newHeight
    }
    
    //MARK: - text view delegate
    
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
