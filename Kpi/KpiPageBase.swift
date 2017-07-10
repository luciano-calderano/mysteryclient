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
//    func subViewResized (newHeight: CGFloat)
    func atchButtonTapped (page: KpiPageQuest)
    func showPageNum (_ num: Int)
}

protocol KpiSubViewDelegate {
    func subViewResized (newHeight: CGFloat)
}

class KpiQuestViewController: KpiViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.scroll.addSubviewWithConstraints(self.kpiPageView)
        self.scroll.contentOffset = CGPoint.zero
    }
}

class KpiViewController: UIViewController {
    class func Instance() -> KpiViewController {
        let vc = self.load(storyboardName: "Kpi") as! KpiViewController
        return vc
    }

    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var content: UIView!
    @IBOutlet var contentH: NSLayoutConstraint!

    var kpi: Job.Kpi!
    var kpiResult: JobResult.KpiResult!
    var delegate: KpiViewDelegate?
    var kpiPageView: KpiPageView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate?.showPageNum((self.navigationController?.viewControllers.count)!)
    }
    
    func checkData() -> KpiResultType {
        return .err
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
    var delegate: KpiSubViewDelegate?
    var kpiResult: JobResult.KpiResult!
    var valuations: [Job.Kpi.Valuations]!
    var valuationSelected: Job.Kpi.Valuations?
    var value = ""
    
    func initialize (kpiResult: JobResult.KpiResult, valuations: [Job.Kpi.Valuations]) {
        self.kpiResult = kpiResult
        self.valuations = valuations
        self.delegate?.subViewResized(newHeight: 1)
    }
}



