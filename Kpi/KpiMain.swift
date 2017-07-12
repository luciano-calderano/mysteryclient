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

class KpiMain: MYViewController, KpiViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    class func Instance() -> KpiMain {
        let vc = self.load(storyboardName: "Kpi") as! KpiMain
        return vc
    }
    
    @IBOutlet private var container: UIView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
   
    private var kpiNavi = UINavigationController()
    private var myKeyboard: MYKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myKeyboard = MYKeyboard(vc: self)
        
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
        }
    }
    
    private func nextKpi () {
        let idx = self.kpiNavi.viewControllers.count - 1
        
        var vc: KpiViewController
        if idx < Config.job.kpis.count {
            vc = KpiQuest.Instance(index: idx)
            self.nextBtn.setTitle(Lng("next"), for: .normal)
        }
        else {
            vc = KpiLast.Instance()
            self.nextBtn.setTitle(Lng("lastPage"), for: .normal)
        }
        vc.delegate = self
        self.kpiNavi.pushViewController(vc, animated: true)
    }

    private func sendKpiResult () {
        self.saveResult()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func imageSelected (_ image: UIImage) {
        let vc = self.kpiNavi.viewControllers.last as! KpiQuest
        vc.attachmentImage = image
    }
    
    private func saveResult () {
        let dict = Config.jobResult.getDict()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)

            let path = NSTemporaryDirectory() + String(Config.job.id) + "/result.json.txt"
            try? jsonData.write(to: URL.init(string: path)!)
            

        } catch {
            print(error.localizedDescription)
        }
        
    }
    // MARK: - Delegate
    
    func showPageNum(_ num: Int) {
        self.header?.header.kpiLabel.isHidden = false
        self.header?.header.kpiLabel.text = "\(num)/\(Config.job.kpis.count + 2)"
    }
    
    // MARK: - Actions
    
    @IBAction func nextTapped () {
        let vc = self.kpiNavi.viewControllers.last as! KpiViewController
        switch vc.checkData() {
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
            self.view.endEditing(true)
            self.kpiNavi.popViewController(animated: true)
        }
    }
    
    //MARK: - mykeyboard function

    func endEditing() {
        self.myKeyboard.endEditing()
    }
    
    func startEditing(scroll: UIScrollView, y: CGFloat) {
        self.myKeyboard.startEditing(scroll: scroll, y: y)
    }
    
    //MARK: - attachment
    
    func atchButtonTapped() {
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
        
        self.present(alert, animated: true) { }
        
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
            let image = pickedImage.resize(CGFloat(Config.maxPicSize))!
            self.imageSelected(image)
        }
        
        self.dismiss(animated: true) { }
    }
}
