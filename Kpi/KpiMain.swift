//
//  KpiMain.swift
//  MysteryClient
//
//  Created by mac on 05/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import Zip


class KpiMain: MYViewController {
    class func Instance() -> KpiMain {
        let vc = InstanceFromSb("Kpi") as! KpiMain
        return vc
    }
    enum ResultType {
        case next
        case last
        
        case errValue
        case errNotes
        case errAttch
        case err
    }

    @IBOutlet private var container: UIView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
   
    private var kpiNavi = UINavigationController()
    private let maxPage = MYJob.shared.job.kpis.count + 2
    
    var currentIndex = -1 {
        didSet {
            showPageNum()
        }
    }
    var myKeyboard: MYKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myKeyboard = MYKeyboard(vc: self)
        
        let path = "\(Config.Path.doc)/\(MYJob.shared.job.id)"
        let fm = FileManager.default
        if fm.fileExists(atPath: path) == false {
            do {
                try fm.createDirectory(atPath: path,
                                       withIntermediateDirectories: true,
                                       attributes: nil)
            } catch let error as NSError {
                print("Unable to create directory \(error.debugDescription)")
            }
        }
        
        if MYJob.shared.jobResult.results.count < MYJob.shared.job.kpis.count {
            for _ in MYJob.shared.jobResult.results.count...MYJob.shared.job.kpis.count - 1 {
                MYJob.shared.jobResult.results.append(JobResult.KpiResult())
            }
            MYResult.shared.saveResult()
        }
        
        headerTitle = MYJob.shared.job.store.name
        
        for btn in [backBtn, nextBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(12)
            btn.setImage(ico, for: .normal)
        }
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        nextBtn.semanticContentAttribute = .forceRightToLeft
        nextBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UINavigationController {
            kpiNavi = segue.destination as! UINavigationController
            let vc = kpiNavi.viewControllers.first as! KpiStart
            vc.delegate = self
            vc.kpiIndex = currentIndex
        }
    }
    
// MARK: - Actions
    
    @IBAction func nextTapped () {
        let vc = kpiNavi.viewControllers.last as! KpiViewController
        switch vc.checkData() {
        case .next:
            nextKpi()
        case .last:
            sendKpiResult()
        case .errValue:
            alert(MYLng("error"), message: MYLng("noValue"), okBlock: nil)
            return
        case .errNotes:
            alert(MYLng("error"), message: MYLng("noNotes"), okBlock: nil)
            return
        case .errAttch:
            alert(MYLng("error"), message: MYLng("noAttch"), okBlock: nil)
            return
        case .err:
            return
        }
    }
    
    @IBAction func prevTapped () {
        switch kpiNavi.viewControllers.count {
        case 1:
            navigationController?.popViewController(animated: true)
        default:
            nextBtn.setTitle(MYLng("next"), for: .normal)
            view.endEditing(true)
            kpiNavi.popViewController(animated: true)
            let vc = kpiNavi.viewControllers.last as! KpiViewController
            currentIndex = vc.kpiIndex
        }
    }
    
//MARK: - Private
    
    private func showPageNum() {
        header?.header.kpiLabel.isHidden = false
        header?.header.kpiLabel.text = "\(currentIndex + 2)/\(maxPage)"
    }
    
    private func nextKpi () {
        currentIndex += 1
        var vc: KpiViewController
        if currentIndex < MYJob.shared.job.kpis.count {
            let kpi = MYJob.shared.job.kpis[currentIndex]
            let id = String(kpi.id)
            let idx = MYJob.shared.invalidDependecies.index(of: id)
            if (idx != nil) {
                nextKpi()
                return
            }
            vc = KpiQuest.Instance()
            vc.kpiIndex = currentIndex
            nextBtn.setTitle(MYLng("next"), for: .normal)
        }
        else {
            vc = KpiLast.Instance()
            nextBtn.setTitle(MYLng("lastPage"), for: .normal)
        }
        vc.delegate = self
        kpiNavi.pushViewController(vc, animated: true)
    }

    private func sendKpiResult () {
        let zip = MYZip()
        let zipUrl = zip.createZipFileWithDict(MYResult.shared.resultDict)
        
        if zipUrl == nil {
            alert("Errore", message: "", okBlock: nil)
            return
        }
        alert(MYLng("readyToSend"), message: "", okBlock: { (ready) in
            let nav = self.navigationController!
            if nav.viewControllers.count > 1 {
                let vc = nav.viewControllers[1]
                nav.popToViewController(vc, animated: true)
            } else {
                nav.popToRootViewController(animated: true)
            }
        })
    }
    
//MARK - Image picker
    
    private let picker = UIImagePickerController()
    func openGallary() {
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func openCamera() {
        picker.delegate = self
        if (UIImagePickerController .isSourceTypeAvailable(.camera)) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Camera Not Found",
                                          message: "This device has no Camera",
                                          preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }

    func imageSelected (_ image: UIImage) {
        let vc = kpiNavi.viewControllers.last as! KpiQuest
        vc.attachmentImage = image
    }
}

//MARK:- KpiViewControllerDelegate

extension KpiMain: KpiViewControllerDelegate {
    //MARK: - mykeyboard function
    func endEditing() {
        myKeyboard.endEditing()
    }
    
    func startEditing(scroll: UIScrollView, y: CGFloat) {
        myKeyboard.startEditing(scroll: scroll, y: y)
    }
    
    //MARK: - attachment tapped
    func atchButtonTapped() {
        let alert = UIAlertController(title: MYLng("uploadPic") as String,
                                      message: "" as String,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction.init(title: MYLng("picFromCam"),
                                           style: .default,
                                           handler: { (action) in
                                            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction.init(title: MYLng("picFromGal"),
                                           style: .default,
                                           handler: { (action) in
                                            self.openGallary()
        }))
        
        present(alert, animated: true) { }
    }
}

//MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension KpiMain: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let image = pickedImage.resize(CGFloat(Config.maxPicSize))!
            imageSelected(image)
        }
        
        dismiss(animated: true) { }
    }
}
