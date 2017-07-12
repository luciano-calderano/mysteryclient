//
//  SubDatePicker.swift
//  MysteryClient
//
//  Created by mac on 11/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit



class SubDatePicker: KpiQuestSubView, UIPickerViewDelegate {
    class func Instance(type: SubDatePicker.PickerType) -> SubDatePicker {
        let id = String (describing: self)
        let me = Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubDatePicker
        me.type = type
        return me
    }

    enum PickerType {
        case time
        case date
        case datetime
    }
    
    @IBOutlet private var kpiPicker: UIDatePicker!
    var type = PickerType.datetime {
        didSet {
//            switch type {
//            case .time:
//                self.kpiPicker.datePickerMode = .time
//            case .date:
//                self.kpiPicker.datePickerMode = .date
//            default:
//                self.kpiPicker.datePickerMode = .dateAndTime
//            }
//            self.kpiPicker.minuteInterval = 15
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.kpiPicker.addTarget(self, action: #selector(pickerUpdate(sender:)),
                                 for: UIControlEvents.valueChanged)
        switch type {
        case .time:
            self.kpiPicker.datePickerMode = .time
        case .date:
            self.kpiPicker.datePickerMode = .date
        default:
            self.kpiPicker.datePickerMode = .dateAndTime
        }
        self.kpiPicker.minuteInterval = 15
    }
    
    override func initialize(kpiResult: JobResult.KpiResult, valuations: [Job.Kpi.Valuations]) {
        super.initialize(kpiResult: kpiResult, valuations: valuations)
        self.kpiPicker.date = kpiResult.value.isEmpty ? Date() :  kpiResult.value.toDate(withFormat: Date.fmtDataOraJson)
        self.delegate?.subViewResized(newHeight: self.frame.size.height)
    }
    
    override func getValuation () -> (value: String, valuation: Job.Kpi.Valuations?) {
        var fmt = ""
        switch type {
        case .time:
            fmt = Date.fmtOra
        case .date:
            fmt = Date.fmtDataJson
        default:
            fmt = Date.fmtDataOraJson
        }
        let value = self.kpiPicker.date.toString(withFormat: fmt)
        return (value, nil)
    }

    func pickerUpdate(sender: UIDatePicker) {
//        self.value = self.kpiPicker.date.toString(withFormat: Date.fmtDataOraJson)
    }

}


