//
//  KpiPageBase.swift
//  MysteryClient
//
//  Created by mac on 07/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

protocol KpiViewDelegate {
    func startEditing (y: CGFloat)
    func endEditing ()
    func subViewResized (newHeight: CGFloat)
}

class KpiViewController: UIViewController {
    var headerCounter: MYLabel!
    var scroll = UIScrollView()
    var delegate: KpiViewDelegate?

    func checkData () -> KpiResultType {
        return .err
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let counter = (self.navigationController?.viewControllers.count)!
        self.headerCounter.isHidden = false
        self.headerCounter.text = "\(counter)/\(Config.job.kpis.count + 1)"
    }
}

class KpiPageView: UIView {
    var kpi: Job.Kpi!
    var kpiResult: JobResult.KpiResult!
    var delegate: KpiViewDelegate?
    
    func checkData() -> KpiResultType {
        return .err
    }
}

class KpiPageSubView: UIView {
    var delegate: KpiViewDelegate?
    var kpiResult: JobResult.KpiResult!
    var valuations: [Job.Kpi.Valuations]!
    
    func initialize (kpiResult: JobResult.KpiResult, valuations: [Job.Kpi.Valuations]) {
        self.kpiResult = kpiResult
        self.valuations = valuations
    }
}



