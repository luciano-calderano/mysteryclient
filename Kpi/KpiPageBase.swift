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
    
    var delegate: KpiViewDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate?.showPageNum((self.navigationController?.viewControllers.count)!)
    }
    
    func checkData() -> KpiResultType {
        return .err
    }
}

class KpiQuestViewController: KpiViewController {
    
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var content: UIView!
    @IBOutlet var contentH: NSLayoutConstraint!
    
    var kpi: Job.Kpi!
    var kpiResult: JobResult.KpiResult!
    var attachmentImage: UIImage? {
        didSet { self.showAtch() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scroll.contentOffset = CGPoint.zero
    }

    func showAtch () {
    }
}

//MARK: -

class KpiQuestSubView: UIView {
    var delegate: KpiQuestSubViewDelegate?
    var kpiResult: JobResult.KpiResult!
    var valuations: [Job.Kpi.Valuations]!
    
    func initialize (kpiResult: JobResult.KpiResult, valuations: [Job.Kpi.Valuations]) {
        self.kpiResult = kpiResult
        self.valuations = valuations
        self.delegate?.subViewResized(newHeight: 1)
    }
    
    func getValuation () -> (value: String, valuation: Job.Kpi.Valuations?) {
        return ("", nil)
    }
}



