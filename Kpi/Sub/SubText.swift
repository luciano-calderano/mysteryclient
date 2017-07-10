//
//  SubText
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubText: KpiPageSubView, UITextFieldDelegate {
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
        self.delegate?.subViewResized(newHeight: self.frame.size.height)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.value = textField.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.value = textField.text!
        textField.resignFirstResponder()
        return true
    }
}


