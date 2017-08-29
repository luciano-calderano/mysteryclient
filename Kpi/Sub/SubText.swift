//
//  SubText
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubText: KpiQuestSubView, UITextFieldDelegate {
    class func Instance() -> SubText {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubText
    }

    @IBOutlet private var kpiText: MYTextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.kpiText.delegate = self
    }
    
    override func initialize(kpiResult: JobResult.KpiResult, valuations: [Job.Kpi.Valuations]) {
        super.initialize(kpiResult: kpiResult, valuations: valuations)
        self.kpiText.text = kpiResult.value
        self.delegate?.subViewResized(newHeight: self.frame.size.height)
    }
    
    override func getValuation () -> KpiResponseValues {
        var response = KpiResponseValues()
        response.value = self.kpiText.text!
        return response
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


