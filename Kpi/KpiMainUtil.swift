//
//  KpiMainUtil.swift
//  MysteryClient
//
//  Created by Lc on 12/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit

protocol KpiDelegate {
    func kpiViewHeight(_ height: CGFloat)
    func kpiStartEditingAtPosY (_ y: CGFloat)
    func kpiEndEditing ()
    func kpiAtchButtonTapped ()
}

extension KpiDelegate {
    func kpiViewHeight(_ height: CGFloat) {}
    func kpiStartEditingAtPosY (_ y: CGFloat) {}
    func kpiEndEditing () {}
    func kpiAtchButtonTapped () {}
}

struct KpiResponseValues {
    var value = ""
    var notesReq = false
    var attchReq = false
    var valuations:[Job.Kpi.Valuation]?
}

enum KpiResultType {
    case next
    case last
    
    case errValue
    case errNotes
    case errAttch
    case err
}

class InvalidValuations {
    private class func fixVValuation (isValid: Bool, dep: Job.Kpi.Valuation.Dependency) {
        if let idx = MYJob.shared.kpiKeyList.index(of: dep.key) {
            MYJob.shared.job.kpis[idx].isValid = isValid
            
            let kpiResult = MYJob.shared.jobResult.results[idx]
            kpiResult.kpi_id = dep.key
            kpiResult.value = isValid ? "" : dep.value
            kpiResult.notes = isValid ? "" : dep.notes
            MYJob.shared.jobResult.results[idx] = kpiResult
        }
    }
    
    class func resetWithKpi (_ kpi: Job.Kpi) {
        for val in kpi.valuations {
            for dep in val.dependencies {
                fixVValuation(isValid: true, dep: dep)
            }
        }
    }
    
    class func updateWithKpi (_ kpi: Job.Kpi, response: KpiResponseValues!) {
        for val in kpi.valuations {
            if val.id == Int(response.value) {
                for dep in val.dependencies {
                    fixVValuation(isValid: false, dep: dep)
                }
            }
        }
    }
}


