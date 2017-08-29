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
    func showPageNum (_ num: Int)
}

protocol KpiQuestSubViewDelegate {
    func subViewResized (newHeight: CGFloat)
}

class KpiViewController: UIViewController {
    class func Instance() -> KpiViewController {
        let vc = self.load(storyboardName: "Kpi") as! KpiViewController
        return vc
    }
    
    var delegate: KpiViewControllerDelegate?
    var nextKpi = 0
    var myKpiIndex = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate?.showPageNum((self.navigationController?.viewControllers.count)!)
    }
    
    func checkData() -> KpiResultType {
        return .err
    }
}

//MARK: -

struct KpiResponseValues {
    var value = ""
    var notes = false
    var attch = false
    var nextKpi = 0
}

class KpiQuestSubView: UIView {
    var delegate: KpiQuestSubViewDelegate?
    var kpiResult: JobResult.KpiResult!
    var valuations: [Job.Kpi.Valuations]!
    
    func initialize (kpiResult: JobResult.KpiResult, valuations: [Job.Kpi.Valuations]) {
        self.kpiResult = kpiResult
        self.valuations = valuations
        self.delegate?.subViewResized(newHeight: 1)
    }
    
    func getValuation () -> KpiResponseValues {
        return KpiResponseValues()
    }
}



