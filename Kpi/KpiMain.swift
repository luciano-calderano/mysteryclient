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
        let id = "KpiMain"
        let sb = UIStoryboard.init(name: "Kpi", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: id)
        return vc as! KpiMain
    }

    @IBOutlet private var container: UIView!
    @IBOutlet private var scroll: UIScrollView!
    @IBOutlet private var backBtn: MYButton!
    @IBOutlet private var nextBtn: MYButton!
    
    private var kpiView: KpiBaseView!
    
    var currentIndex = -1
    var myKeyboard: MYKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentIndex < 0 {
            kpiView = KpiInitView.Instance()
        } else if currentIndex == MYJob.shared.job.kpis.count {
            kpiView = KpiLastView.Instance()
        } else {
            kpiView = KpiQuestView.Instance()
            kpiView.kpiIndex = currentIndex
            kpiView.mainVC = self
            scroll.backgroundColor = UIColor.white
        }
        kpiView.delegate = self
        scroll.addSubviewWithConstraints(kpiView)
        showPageNum()

        myKeyboard = MYKeyboard(vc: self, scroll: scroll)
        
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
        switch kpiView.checkData() {
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
        if let label = header?.header.kpiLabel {
            label.isHidden = false
            label.text = "\(currentIndex + 2)/\(MYJob.shared.job.kpis.count + 2)"
        }
    }
    
    private func nextKpi () {
        func loadCtrl (index: Int) {
            let vc = KpiMain.Instance()
            vc.currentIndex = index
            self.navigationController?.pushViewController(vc, animated: true)
            let title = index == MYJob.shared.job.kpis.count ? "lastPage" : "next"
            nextBtn.setTitle(MYLng(title), for: .normal)
        }
        
        let lastKpi = MYJob.shared.job.kpis.count - 1
        if currentIndex == lastKpi {
            loadCtrl(index: MYJob.shared.job.kpis.count)
            return
        }
        for index in currentIndex + 1...lastKpi {
            let kpi = MYJob.shared.job.kpis[index]
            let id = String(kpi.id)
            if MYJob.shared.invalidDependecies.index(of: id) == nil {
                loadCtrl(index: index)
                return
            }
        }
    }
}

//MARK:- KpiDelegate

extension KpiMain: KpiDelegate {
    func kpiEndEditing() {
        myKeyboard.endEditing()
    }

    func kpiStartEditingAtPosY(_ y: CGFloat) {
        myKeyboard.startEditing(y: y)
    }
}

extension KpiMain {
    private func sendKpiResult () {
        guard MYZip().createZipFileWithDict(MYResult.shared.resultDict) else {
            alert ("Errore zip", message: "", okBlock: nil)
            return
        }
        alert (MYLng("readyToSend"), message: "", okBlock: {
            (ready) in
            let nav = self.navigationController!
            if nav.viewControllers.count > 1 {
                let vc = nav.viewControllers[1]
                nav.popToViewController(vc, animated: true)
            } else {
                nav.popToRootViewController(animated: true)
            }
        })
    }
}
