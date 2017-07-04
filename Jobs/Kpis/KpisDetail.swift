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
    
    @IBOutlet private var scroll: UIScrollView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addKeybNotification()
        self.loadKpi(index: self.index)
        
        for btn in [self.backBtn, self.nextBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(12)
            btn.setImage(ico, for: .normal)
        }

        self.backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        self.nextBtn.semanticContentAttribute = .forceRightToLeft
        self.nextBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    private func loadKpi (index: Int) {
        
        self.kpi = self.job.kpis[index]
        self.headerTitle = self.kpi.service + " (\(index + 1) / \(self.job.kpis.count))"
        
        var kpiSub: KpiSubView!
        
        switch self.kpi.type {
        case "radio" :
            kpiSub = KpiRadio.Instance()
        default:
            return
        }

        self.scroll.addSubviewWithConstraints(kpiSub)
        kpiSub.updateKpi(kpi: self.kpi)
        kpiSub.delegate = self
    }
    
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
    func updateKpi (kpi: Kpi) {
        self.kpi = kpi
    }
    
    func checkResult () -> Bool {
        return false
    }
}


