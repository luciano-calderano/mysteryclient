//
//  KpiMain.swift
//  MysteryClient
//
//  Created by mac on 05/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import Zip

//protocol SubKpiDelegate {
//    func subKpiNewHeigth (height: CGFloat)
//}

class KpisSubView: UIView {
    var delegate: KpiQuestSubViewDelegate?
//    var subKpiDelegate: SubKpiDelegate?
    var currentKpi: Job.Kpi!
    var kpiResult: JobResult.KpiResult!
    var kpiIndex = 0 {
        didSet {
            initialize()
        }
    }
    
    func initialize () {
        currentKpi = MYJob.shared.job.kpis[kpiIndex]
        kpiResult = MYJob.shared.jobResult.results[kpiIndex]
//        subKpiDelegate?.subKpiNewHeigth(height: 1)
    }
    
    func getValuation () -> KpiResponseValues {
        return KpiResponseValues()
    }
    
    func checkData() -> KpiMain.ResultType {
        return .err
    }
    
}

class KMain: MYViewController {
    class func Instance() -> KMain {
        let id = "KMain"
        let sb = UIStoryboard.init(name: "Kpis", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: id)
        return vc as! KMain
    }
    enum KpiResultType {
        case next
        case last
        
        case errValue
        case errNotes
        case errAttch
        case err
    }
    
    @IBOutlet private var container: UIView!
    @IBOutlet private var scroll: UIScrollView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    
    private let maxPage = MYJob.shared.job.kpis.count + 2
    private var kpiSubView: KpisSubView!
    
    var currentIndex = -1
    var myKeyboard: MYKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentIndex < 0 {
            pageZero()
            kpiSubView = SubMain.Instance()
        } else {
            kpiSubView = SubKpi.Instance()
//            kpiSubView.subKpiDelegate = self
            kpiSubView.kpiIndex = currentIndex
            showPageNum()
        }
        scroll.addSubviewWithConstraints(kpiSubView)

        myKeyboard = MYKeyboard(vc: self)
        
        headerTitle = MYJob.shared.job.store.name
        
        for btn in [backBtn, nextBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(12)
            btn.setImage(ico, for: .normal)
        }
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        nextBtn.semanticContentAttribute = .forceRightToLeft
        nextBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    override func headerViewSxTapped() {
        let vc = self.navigationController?.viewControllers[2]
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func nextTapped () {
        switch kpiSubView.checkData() {
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
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Private
    
    private func showPageNum() {
        header?.header.kpiLabel.isHidden = false
        header?.header.kpiLabel.text = "\(currentIndex + 1)/\(maxPage)"
    }
    
    private func nextKpi () {
        for index in currentIndex + 1...MYJob.shared.job.kpis.count - 1 {
            let kpi = MYJob.shared.job.kpis[index]
            let id = String(kpi.id)
            if MYJob.shared.invalidDependecies.index(of: id) == nil {
                let vc = KMain.Instance()
                vc.currentIndex = index
                self.navigationController?.pushViewController(vc, animated: true)
                nextBtn.setTitle(MYLng("next"), for: .normal)
                return
            }
        }
        
        
        //        currentIndex += 1
        //        if currentIndex < MYJob.shared.job.kpis.count {
        //            let kpi = MYJob.shared.job.kpis[currentIndex]
        //            let id = String(kpi.id)
        //            let idx = MYJob.shared.invalidDependecies.index(of: id)
        //            if (idx != nil) {
        //                nextKpi()
        //                return
        //            }
        //            let vc = KMain.Instance()
        //            vc.currentIndex = currentIndex
        //            self.navigationController?.pushViewController(vc, animated: true)
        //            nextBtn.setTitle(MYLng("next"), for: .normal)
        //        }
        //        else {
        //            vc = KpiLast.Instance()
        //            nextBtn.setTitle(MYLng("lastPage"), for: .normal)
        //        }
        //        vc.delegate = self
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
        let vc = self.navigationController?.viewControllers.last as! KpiQuest
        vc.attachmentImage = image
    }
}

//MARK:- KpiViewControllerDelegate

extension KMain: KpiViewControllerDelegate {
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

extension KMain: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

//extension KMain: SubKpiDelegate {
//    func subKpiNewHeigth(height: CGFloat) {
//        scroll.contentSize = CGSize.init(width: scroll.frame.size.width, height: height)
//    }
//}

extension KMain {
    private func pageZero () {
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
    }
    
}
