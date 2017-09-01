//
//  KpiPageBase.swift
//  MysteryClient
//
//  Created by mac on 07/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

protocol KpiViewControllerDelegate {
    func startEditing (scroll: UIScrollView, y: CGFloat)
    func endEditing ()
    func atchButtonTapped ()
}

protocol KpiQuestSubViewDelegate {
    func kpiQuestSubViewNewHeight (_ newHeight: CGFloat)
}

class KpiViewController: UIViewController {
    class func Instance() -> KpiViewController {
        let vc = self.load(storyboardName: "Kpi") as! KpiViewController
        return vc
    }
    
    var delegate: KpiViewControllerDelegate?
    var kpiIndex = 0

    func checkData() -> KpiResultType {
        return .err
    }
}

//MARK:-

struct KpiResponseValues {
    var value = ""
    var notesReq = false
    var attchReq = false
    var valuations:[Job.Kpi.Valuation]?
}

class KpiQuestSubView: UIView {
    var delegate: KpiQuestSubViewDelegate?
    var kpi: Job.Kpi!
    var kpiResult: JobResult.KpiResult!

    func initialize (kpiIndex: Int) {
        self.kpi = MYJob.shared.job.kpis[kpiIndex]
        self.kpiResult = MYJob.shared.jobResult.results[kpiIndex]
        self.delegate?.kpiQuestSubViewNewHeight(1)
    }

    func getValuation () -> KpiResponseValues {
        return KpiResponseValues()
    }
}



