//
//  KpiMain.swift
//  MysteryClient
//
//  Created by mac on 05/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

enum KpiResultType {
    case next
    case home
    case err
}

class KpiMain: MYViewController, KpiViewControllerDelegate {
    class func Instance(job: Job, jobResult: JobResult) -> KpiMain {
        let vc = self.load(storyboardName: "Kpi") as! KpiMain
        vc.job = job
        vc.jobResult = jobResult
        return vc
    }
    
    @IBOutlet private var scroll: UIScrollView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    
    private var kpiNavi = UINavigationController()
    private var kpiCtrl: KpiViewController!
    private var kpiIndex = -1
    
    var job: Job!
    var jobResult: JobResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.kpiCtrl = KpiFirst.Instance()
        self.kpiCtrl.job = self.job
        self.kpiCtrl.jobResult = self.jobResult

        self.kpiNavi = UINavigationController(rootViewController:self.kpiCtrl)
        self.kpiNavi.navigationBar.isHidden = true
        self.addChildViewController(self.kpiNavi)
        
        self.kpiNavi.view.frame = self.scroll.bounds
        self.scroll.addSubview(self.kpiNavi.view)
        
        for btn in [self.backBtn, self.nextBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(12)
            btn.setImage(ico, for: .normal)
        }
        self.backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        self.nextBtn.semanticContentAttribute = .forceRightToLeft
        self.nextBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    private func gotoKpi () {
        let kpi = self.job.kpis[self.kpiIndex]
        self.headerTitle = kpi.service + " (\(self.kpiIndex + 1) / \(self.job.kpis.count))"
        
        switch kpi.type {
        case "radio" :
            self.kpiCtrl = KpiRadio.Instance()
        default:
            return
        }
        
        self.kpiCtrl.kpi = kpi
        self.kpiCtrl.job = self.job
        self.kpiCtrl.jobResult = self.jobResult
        if self.kpiIndex < self.jobResult.results.count {
            self.kpiCtrl.kpiResult = self.jobResult.results[self.kpiIndex]
        }
        else {
            self.kpiCtrl.kpiResult = JobResult.KpiResult()
        }
        self.kpiCtrl.delegate = self
        self.kpiNavi.pushViewController(self.kpiCtrl, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func nextTapped () {
        switch self.kpiCtrl.checkData() {
        case .home:
            self.navigationController?.popToRootViewController(animated: true)
        case .next:
            self.kpiIndex += 1
            self.gotoKpi()
        case .err:
            return
        }
    }
    
    @IBAction func prevTapped () {
        self.kpiIndex -= 1
        
        switch self.kpiNavi.viewControllers.count {
        case 1:
            self.navigationController?.popViewController(animated: true)
        default:
            self.kpiNavi.popViewController(animated: true)
        }
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
    func endEditing() {
        self.scroll.contentOffset = self.prevOffset
    }
    
    func startEditing(y: CGFloat) {
        self.prevOffset = self.scroll.contentOffset
        var offset = self.scroll.contentOffset
        offset.y = y
        self.scroll.contentOffset = offset
    }
}

protocol KpiViewControllerDelegate {
    func startEditing (y: CGFloat)
    func endEditing ()
}

class KpiViewController: UIViewController {
    var job: Job!
    var kpi: Job.Kpi!
    var jobResult: JobResult!
    var kpiResult: JobResult.KpiResult!
    var delegate: KpiViewControllerDelegate?
    
    func checkData () -> KpiResultType {
        return .err
    }
    
}

