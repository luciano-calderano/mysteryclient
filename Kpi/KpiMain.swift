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
    case last
    case errValue
    case errNotes
    case errAttch
    case err
}

class KpiMain: MYViewController, KpiViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UINavigationController {
            self.kpiNavi = segue.destination as! UINavigationController
            let vc = self.kpiNavi.viewControllers.first as! KpiStart
            
            vc.delegate = self
            self.kpiViewController = vc
        }
    }
    
    private func nextKpi () {
        let idx = self.kpiNavi.viewControllers.count - 1
        
        if Config.job.kpis.count < idx {
            let vc = KpiLast.Instance()
            vc.delegate = self
            self.kpiNavi.pushViewController(vc, animated: true)
            self.kpiViewController = vc
            return
        }
        let vc = KpiQuest.Instance()
        vc.delegate = self
//        vc.kpi = Config.job.kpis[idx]
//        vc.kpiResult = Config.jobResult.results[idx]
        self.kpiNavi.pushViewController(vc, animated: true)
        self.kpiViewController = vc
    }
    
//    private func lastKpi () -> KpiViewController {
//        self.showKpiCounter()
//        self.nextBtn.setTitle(Lng("lastPage"), for: .normal)
//        
//        let vc = KpiViewController()
//        vc.delegate = self
//        vc.headerCounter = self.header?.header.kpiLabel
//
//        vc.kpiPageView = KpiPageLast.Instance()
//        vc.kpiPageView.delegate = self
//        
//        self.kpiNavi.pushViewController(vc, animated: true)
////        vc.view.addSubviewWithConstraints(vc.scroll)
//        vc.scroll.addSubviewWithConstraints(vc.kpiPageView)
//        self.showKpiCounter()
//
//        return vc
//    }
    
    // MARK: - Delegate
    
    func showPageNum(_ num: Int) {
        self.header?.header.kpiLabel.isHidden = false
        self.header?.header.kpiLabel.text = "\(num)/\(Config.job.kpis.count + 2)"
    }
    
    private func sendKpiResult () {
        self.navigationController?.popToRootViewController(animated: true)        
    }
    
    // MARK: - Actions
    
    @IBAction func nextTapped () {
        switch self.kpiViewController.checkData() {
        case .home:
            self.navigationController?.popToRootViewController(animated: true)
        case .last:
            self.sendKpiResult()
        case .next:
            self.nextKpi()
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
            self.nextBtn.setTitle(Lng("next"), for: .normal)
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
    
    func atchButtonTapped(page: KpiPageQuest) {
        let alert = UIAlertController(title: Lng("uploadPic") as String,
                                      message: "" as String,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction.init(title: Lng("picFromCam"),
                                           style: .default,
                                           handler: { (action) in
                                            self.openCamera()
        }))
        alert.addAction(UIAlertAction.init(title: Lng("picFromGal"),
                                           style: .default,
                                           handler: { (action) in
                                            self.openGallary()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Image picker
    
    private let picker = UIImagePickerController()
    func openGallary() {
        self.picker.delegate = self
        self.picker.allowsEditing = false
        self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(self.picker, animated: true, completion: nil)
    }
    
    func openCamera() {
        self.picker.delegate = self
        if (UIImagePickerController .isSourceTypeAvailable(.camera)) {
            self.picker.allowsEditing = false
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.picker.cameraCaptureMode = .photo
            self.present(self.picker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Camera Not Found",
                                          message: "This device has no Camera",
                                          preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let image = pickedImage.resize(1200)!
            print(image.size)
            let page = self.kpiViewController.kpiPageView!
            let file = String(page.kpi.id)
            let result = String(page.kpiResult.kpi_id)
            self.kpiViewController.kpiPageView.kpiResult.attachment = file + "." + result
        }
        self.dismiss(animated: true, completion: nil)
    }
}
