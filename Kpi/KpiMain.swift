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
    @IBOutlet private var container: UIView!

    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    
    private var kpiNavi = UINavigationController()
    private var kpiPage: KpiViewController!

    private var kpiSubView: KpiSubView!

    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scroll.contentSize = self.kpiPage.view.frame.size
    }
    
    private func loadVc () {
        self.kpiPage = KpiViewController()
        self.kpiPage.delegate = self
        self.kpiPage.headerCounter = self.header?.header.kpiLabel
        self.kpiPage.view.addSubviewWithConstraints(self.kpiPage.scroll)

        self.kpiSubView.scroll = self.kpiPage.scroll
        self.kpiPage.scroll.addSubviewWithConstraints(self.kpiSubView)
    }
    
    private func firstKpi () {
        self.kpiSubView = SubFirst.Instance()
        self.loadVc()
        
        self.kpiNavi = UINavigationController(rootViewController:self.kpiPage)
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
        self.kpiSubView = SubPage.Instance()
        self.kpiSubView.kpi = Config.job.kpis[idx]
        self.kpiSubView.kpiResult = Config.jobResult.results[idx]
//        self.loadVc()
        self.kpiPage = KpiViewController()
        self.kpiPage.delegate = self
        self.kpiPage.headerCounter = self.header?.header.kpiLabel

        self.kpiNavi.pushViewController(self.kpiPage, animated: true)
        self.kpiPage.view.addSubviewWithConstraints(self.kpiPage.scroll)
        
        self.kpiSubView.scroll = self.kpiPage.scroll
        self.kpiPage.scroll.addSubviewWithConstraints(self.kpiSubView)
    }
    
    private func lastKpi () {
    }
    // MARK: - Actions
    
    @IBAction func nextTapped () {
        switch self.kpiSubView.checkData() {
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
            self.kpiPage.view.endEditing(true)
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

protocol KpiViewControllerDelegate {
    func startEditing (y: CGFloat)
    func endEditing ()
}

class KpiViewController: UIViewController {
    var headerCounter: MYLabel!
    var delegate: KpiViewControllerDelegate?
    var scroll = UIScrollView()
    
    func checkData () -> KpiResultType {
        return .err
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let counter = (self.navigationController?.viewControllers.count)!
        self.headerCounter.isHidden = false
        self.headerCounter.text = "\(counter)/\(Config.job.kpis.count + 1)"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var contentSize = self.scroll.contentSize
        contentSize.height += 300
        self.scroll.contentSize = contentSize
        

    }
}
