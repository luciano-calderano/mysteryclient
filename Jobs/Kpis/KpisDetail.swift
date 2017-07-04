//
//  KpisDetail
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpisDetail: MYViewController, KpiSubViewDelegate {
    class func Instance(job: Job, index: Int) -> KpisDetail {
        let vc = self.load(storyboardName: "Jobs") as! KpisDetail
        vc.job = job
        vc.index = index
        return vc
    }

    var job: Job!
    var index = 0
    
    private var kpi: Kpi!
    private var jobResult = JobResult()
    private var kpiSub: KpiSubView!
    
    @IBOutlet private var scroll: UIScrollView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addKeybNotification()
        
        self.loadKpi()
        self.jobResult.load(id: self.job.id)
        
        for btn in [self.backBtn, self.nextBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(12)
            btn.setImage(ico, for: .normal)
        }

        self.backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        self.nextBtn.semanticContentAttribute = .forceRightToLeft
        self.nextBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    private func loadKpi () {
        self.kpi = self.job.kpis[self.index]
        if  self.index < self.jobResult.results.count {
            let kpiResult = self.jobResult.results[self.index]
            self.kpiSub.value = kpiResult.value
            self.kpiSub.notes = kpiResult.notes
        }
        self.headerTitle = self.kpi.service + " (\(index + 1) / \(self.job.kpis.count))"
        
        switch self.kpi.type {
        case "radio" :
            self.kpiSub = KpiRadio.Instance()
        default:
            return
        }

        self.scroll.addSubviewWithConstraints(kpiSub)
        self.kpiSub.updateKpi(kpi: self.kpi)
        self.kpiSub.delegate = self
    }
    
    //MARK: - Navigation

    @IBAction func nextKpi() {
        if self.kpiSub.checkResult() == false {
            return
        }
        
        let kpiResult = JobResult.KpiResult()
        kpiResult.value = self.kpiSub.value
        kpiResult.notes = self.kpiSub.notes
        
        if self.jobResult.results.count > self.index {
            self.jobResult.results[self.index] = kpiResult
        }
        else {
            self.jobResult.results.append(kpiResult)
        }
        
        self.kpiSub.removeFromSuperview()
        self.index += 1
        if self.index >= self.job.kpis.count {
            return
        }
        self.loadKpi()
    }

    @IBAction func prevKpi() {
        self.kpiSub.removeFromSuperview()
        self.index -= 1
        if self.index < 0 {
            self.navigationController?.popViewController(animated: true)
        }
        self.loadKpi()
    }

    //MARK: - keyboard function
    
    private func addKeybNotification () {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(notification:)),
                                               name:NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(notification:)),
                                               name:NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func keyboardWillShow (notification: NSNotification) {
        let sizeValue = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let h = sizeValue.cgRectValue.size.height
        self.scroll.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: h, right: 0)
    }
    
    func keyboardWillHide (notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsets.zero
    }
    
    //MARK: - setting offset
    
    var prevOffset = CGPoint.zero
    func subViewEndEditing() {
        self.scroll.contentOffset = self.prevOffset
    }
    
    func subViewStartEditing(y: CGFloat) {
        self.prevOffset = self.scroll.contentOffset
        var offset = self.scroll.contentOffset
        offset.y = y
        self.scroll.contentOffset = offset
    }
}

protocol KpiSubViewDelegate {
    func subViewStartEditing (y: CGFloat)
    func subViewEndEditing ()
}

class KpiSubView: UIView {
    var kpi: Kpi!
    var delegate: KpiSubViewDelegate?
    
    var value = ""
    var notes = ""
    var attch = ""
    
    func updateKpi (kpi: Kpi) {
        self.kpi = kpi
    }
    
    func checkResult () -> Bool {
        assertionFailure("override: checkResult")
        return false
    }
}


