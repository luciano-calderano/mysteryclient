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

class QuestDependency {
    var result: KpiResponseValues!
    init(withResult r: KpiResponseValues) {
        result = r
    }
    
    func update (withReset: Bool) {
        if withReset {
            for val in result.valuations! {
                updateInvalidKpiWithDep(val, isReset: true)
            }
            print("reset \(MYJob.shared.invalidDependecies)")
        }
        for val in result.valuations! {
            if val.id == Int(result.value) {
                updateInvalidKpiWithDep(val, isReset: false)
            }
        }
        print("fix \(MYJob.shared.invalidDependecies)")
    }
    
    private func updateInvalidKpiWithDep (_ val: Job.Kpi.Valuation, isReset: Bool) {
        for dep in val.dependencies {
            let idIndex = MYJob.shared.kpiKeyList.index(of: dep.key)
            if idIndex == nil {
                return
            }
            let index = idIndex!
            
            let kpiResult = MYJob.shared.jobResult.results[index]
            kpiResult.kpi_id = dep.key
            if isReset {
                kpiResult.value = ""
                kpiResult.notes = ""
                
            } else {
                kpiResult.value = dep.value
                kpiResult.notes = dep.notes
            }
            MYJob.shared.jobResult.results[index] = kpiResult
            
            let idx = MYJob.shared.invalidDependecies.index(of: String(dep.key))
            if isReset {
                if (idx != nil) {
                    MYJob.shared.invalidDependecies.remove(at: idx!)
                }
            } else {
                if (idx == nil) {
                    MYJob.shared.invalidDependecies.append(String(dep.key))
                }
            }
        }
    }
}


