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
    var type = PickerType.datetime
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switch type {
        case .time:
            kpiPicker.datePickerMode = .time
        case .date:
            kpiPicker.datePickerMode = .date
        default:
            kpiPicker.datePickerMode = .dateAndTime
        }
        kpiPicker.minuteInterval = 15
    }
    
    override func initialize(kpiIndex: Int) {
        super.initialize(kpiIndex: kpiIndex)
        kpiPicker.date = kpiResult.value.isEmpty ? Date() :  kpiResult.value.toDate(withFormat: Config.DateFmt.DataOraJson)
        self.delegate?.kpiQuestSubViewNewHeight(self.frame.size.height)
    }
    
    override func getValuation () -> KpiResponseValues {
        var response = KpiResponseValues()
        var fmt = ""
        switch type {
        case .time:
            fmt = Config.DateFmt.Ora
        case .date:
            fmt = Config.DateFmt.DataJson
        default:
            fmt = Config.DateFmt.DataOraJson
        }
        response.value = kpiPicker.date.toString(withFormat: fmt)
        return response
    }
}


