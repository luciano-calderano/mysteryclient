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
    case errValue
    case errNotes
    case errAttch
    case err
}

class KpiMain: MYViewController, KpiViewDelegate {
    class func Instance() -> KpiMain {
        let vc = self.load(storyboardName: "Kpi") as! KpiMain
        return vc
    }
    
    @IBOutlet private var container: UIView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    
    private var kpiNavi = UINavigationController()
    private var kpiViewController: KpiViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSTemporaryDirectory() + "/" + String(Config.job.id)
        let fm = FileManager.default
        if fm.fileExists(atPath: path) == false {
            do {
                try fm.createDirectory(atPath: path,
                                       withIntermediateDirectories: true,
                                       attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        
        if Config.jobResult.results.count < Config.job.kpis.count {
            for _ in Config.jobResult.results.count...Config.job.kpis.count - 1 {
                Config.jobResult.results.append(JobResult.KpiResult())
            }
            Config.jobResult.save()
        }
        
        self.kpiViewController = self.firstKpi()
        self.addKeybNotification()
        self.headerTitle = Config.job.store.name
        
        for btn in [self.backBtn, self.nextBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(12)
            btn.setImage(ico, for: .normal)
        }
        self.backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        self.nextBtn.semanticContentAttribute = .forceRightToLeft
        self.nextBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    private func firstKpi () -> KpiViewController {
        let vc = KpiViewController()

        vc.delegate = self
        vc.headerCounter = self.header?.header.kpiLabel
        vc.view.addSubviewWithConstraints(vc.scroll)
        vc.kpiPageView = KpiPageFirst.Instance()
        vc.scroll.addSubviewWithConstraints(vc.kpiPageView)
        
        self.kpiNavi = UINavigationController(rootViewController:vc)
        self.kpiNavi.navigationBar.isHidden = true
        self.kpiNavi.view.frame = self.container.bounds
        self.addChildViewController(self.kpiNavi)
        self.container.addSubview(self.kpiNavi.view)
        
        return vc
    }
    
    private func nextKpi () -> KpiViewController {
        let idx = self.kpiNavi.viewControllers.count - 1
        if Config.job.kpis.count < idx {
            self.lastKpi()
            return KpiViewController()
        }
        let vc = KpiViewController()
        vc.delegate = self
        vc.headerCounter = self.header?.header.kpiLabel

        vc.kpiPageView = KpiPageQuest.Instance()
        vc.kpiPageView.delegate = self
        vc.kpiPageView.kpi = Config.job.kpis[idx]
        vc.kpiPageView.kpiResult = Config.jobResult.results[idx]

        self.kpiNavi.pushViewController(vc, animated: true)
        vc.view.addSubviewWithConstraints(vc.scroll)
        vc.scroll.addSubviewWithConstraints(vc.kpiPageView)
        
        return vc
    }
    
    private func lastKpi () {
        let vc = KpiViewController()
        vc.delegate = self
        vc.headerCounter = self.header?.header.kpiLabel

        vc.kpiPageView = KpiPageLast.Instance()
        vc.kpiPageView.delegate = self
        
        self.kpiNavi.pushViewController(vc, animated: true)
        vc.view.addSubviewWithConstraints(vc.scroll)
        vc.scroll.addSubviewWithConstraints(vc.kpiPageView)
    }
    
    // MARK: - Actions
    
    @IBAction func nextTapped () {
        switch self.kpiViewController.kpiPageView.checkData() {
        case .home:
            self.navigationController?.popToRootViewController(animated: true)
        case .next:
            self.kpiViewController = self.nextKpi()
        case .errValue:
            self.alert(Lng("error"), message: Lng("noValue"), okBlock: nil)
            return
        case .errNotes:
            self.alert(Lng("error"), message: Lng("noNotes"), okBlock: nil)
            return
        case .errAttch:
            self.alert(Lng("error"), message: Lng("noAttch"), okBlock: nil)
            return
        case .err:
            return
        }
    }
    
    @IBAction func prevTapped () {
        switch self.kpiNavi.viewControllers.count {
        case 1:
            self.navigationController?.popViewController(animated: true)
        default:
            self.kpiViewController.view.endEditing(true)
            self.kpiNavi.popViewController(animated: true)
            self.kpiViewController = self.kpiNavi.viewControllers.last as! KpiViewController
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
        self.kpiViewController.scroll.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: h, right: 0)
    }
    
    func keyboardWillHide (notification: NSNotification) {
        self.kpiViewController.scroll.contentInset = UIEdgeInsets.zero
    }
    
    //MARK: - setting offset
    
    var prevOffset = CGPoint.zero
    func endEditing() {
        self.kpiViewController.scroll.contentOffset = self.prevOffset
    }
    
    func startEditing(y: CGFloat) {
        self.prevOffset = self.kpiViewController.scroll.contentOffset
        var offset = self.kpiViewController.scroll.contentOffset
        offset.y = y
        self.kpiViewController.scroll.contentOffset = offset
    }
    
    func subViewResized(newHeight: CGFloat) {
        var contentSize = self.kpiViewController.scroll.contentSize
        contentSize.height += 300
        self.kpiViewController.scroll.contentSize = contentSize
    }
}
