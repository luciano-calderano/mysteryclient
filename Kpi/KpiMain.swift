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
    class func Instance() -> KpiMain {
        let vc = self.load(storyboardName: "Kpi") as! KpiMain
        return vc
    }
    
    @IBOutlet private var scroll: UIScrollView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    
    private var kpiNavi = UINavigationController()
    private var kpiCtrl: KpiViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addKeybNotification()
        
        self.kpiCtrl = KpiFirst.Instance()

        self.kpiNavi = UINavigationController(rootViewController:self.kpiCtrl)
        self.kpiNavi.navigationBar.isHidden = true
        self.addChildViewController(self.kpiNavi)
        
        self.kpiNavi.view.frame = self.scroll.bounds
        self.scroll.addSubview(self.kpiNavi.view)
        self.kpiCtrl.header = self.header?.header
        
        for btn in [self.backBtn, self.nextBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(12)
            btn.setImage(ico, for: .normal)
        }
        self.backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        self.nextBtn.semanticContentAttribute = .forceRightToLeft
        self.nextBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    private func nextKpi () {
        let idx = self.kpiNavi.viewControllers.count - 1
        let kpi = Config.job.kpis[idx]
        
        switch kpi.type {
        case "radio" :
            self.kpiCtrl = KpiRadio.Instance()
        default:
            return
        }
        
        self.kpiCtrl.kpi = kpi
        self.kpiCtrl.delegate = self
        self.kpiCtrl.header = self.header?.header
        self.kpiCtrl.view.endEditing(true)
        self.kpiNavi.pushViewController(self.kpiCtrl, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func nextTapped () {
        switch self.kpiCtrl.checkData() {
        case .home:
            self.navigationController?.popToRootViewController(animated: true)
        case .next:
            self.nextKpi()
        case .err:
            return
        }
    }
    
    @IBAction func prevTapped () {
        switch self.kpiNavi.viewControllers.count {
        case 1:
            self.navigationController?.popViewController(animated: true)
        default:
            self.kpiCtrl.view.endEditing(true)
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
        let kbSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let h = kbSize.cgRectValue.size.height
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

    // MARK: -

protocol KpiViewControllerDelegate {
    func startEditing (y: CGFloat)
    func endEditing ()
}

class KpiViewController: UIViewController {
    var kpi: Job.Kpi!
    var kpiResult: JobResult.KpiResult!
    var delegate: KpiViewControllerDelegate?
    var header: HeaderView!
    
    func checkData () -> KpiResultType {
        return .err
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let idx = (self.navigationController?.viewControllers.count)! - 2
        if idx < 0 {
            self.header.titleLabel.text = Config.job.store.name
        }
        else {
            if idx >= Config.jobResult.results.count {
                Config.jobResult.results.append(JobResult.KpiResult())
            }
            self.kpi = Config.job.kpis[idx]
            self.kpiResult = Config.jobResult.results[idx]
            self.header.titleLabel.text = kpi.service + " (\(idx + 1) / \(Config.job.kpis.count))"
        }
    }
}

