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

class KpiMain: MYViewController, KpiViewDelegate {
    class func Instance() -> KpiMain {
        let vc = self.load(storyboardName: "Kpi") as! KpiMain
        return vc
    }
    
    @IBOutlet private var scroll: UIScrollView!
    @IBOutlet private var container: UIView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    
    private var kpiNavi = UINavigationController()
    private var kpiViewController: KpiViewController!
    private var kpiPageView: KpiPageView!

    
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
        
        self.firstKpi()
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
    
    private func firstKpi () {
        self.kpiPageView = KpiPageFirst.Instance()
        
        self.kpiViewController = KpiViewController()
        self.kpiViewController.delegate = self
        self.kpiViewController.headerCounter = self.header?.header.kpiLabel
        self.kpiViewController.view.addSubviewWithConstraints(self.kpiViewController.scroll)
        self.kpiViewController.scroll.addSubviewWithConstraints(self.kpiPageView)
        
        self.kpiNavi = UINavigationController(rootViewController:self.kpiViewController)
        self.kpiNavi.navigationBar.isHidden = true
        self.kpiNavi.view.frame = self.container.bounds
        self.addChildViewController(self.kpiNavi)
        self.container.addSubview(self.kpiNavi.view)
    }
    
    private func nextKpi () {
        let idx = self.kpiNavi.viewControllers.count - 1
        if Config.job.kpis.count < idx {
            self.lastKpi()
            return
        }
        self.kpiPageView = KpiPageQuest.Instance()
        self.kpiPageView.delegate = self
        self.kpiPageView.kpi = Config.job.kpis[idx]
        self.kpiPageView.kpiResult = Config.jobResult.results[idx]

        self.kpiViewController = KpiViewController()
        self.kpiViewController.delegate = self
        self.kpiViewController.headerCounter = self.header?.header.kpiLabel
        
        self.kpiNavi.pushViewController(self.kpiViewController, animated: true)
        self.kpiViewController.view.addSubviewWithConstraints(self.kpiViewController.scroll)
        self.kpiViewController.scroll.addSubviewWithConstraints(self.kpiPageView)
    }
    
    private func lastKpi () {
    }
    // MARK: - Actions
    
    @IBAction func nextTapped () {
        switch self.kpiPageView.checkData() {
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
            self.kpiViewController.view.endEditing(true)
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
    
    func subViewResized(newHeight: CGFloat) {
        var contentSize = self.scroll.contentSize
        contentSize.height += 300
        self.scroll.contentSize = contentSize
    }
}
