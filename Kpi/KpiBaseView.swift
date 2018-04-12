//
//  KpisSubView.swift
//  MysteryClient
//
//  Created by Lc on 11/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit

class KpiBaseSubView: UIView {
    var delegate: KpiDelegate?
    var currentKpi: Job.Kpi!
    var kpiResult: JobResult.KpiResult!

    func getValuation () -> KpiResponseValues {
        return KpiResponseValues()
    }
}

class KpiBaseView: UIView {
    var delegate: KpiDelegate?
    var mainVC: KpiMain!
    var currentKpi: Job.Kpi!
    var kpiResult: JobResult.KpiResult!
    var kpiIndex = 0 {
        didSet {
            currentKpi = MYJob.shared.job.kpis[kpiIndex]
            kpiResult = MYJob.shared.jobResult.results[kpiIndex]
            initialize()
        }
    }
    
    func initialize () {
    }
    
    func checkData() -> KpiResultType {
        return .err
    }    
}
