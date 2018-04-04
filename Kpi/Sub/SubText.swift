//
//  SubText
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubText: KpiQuestSubView {
    class func Instance() -> SubText {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubText
    }

    @IBOutlet private var kpiText: MYTextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.kpiText.delegate = self
    }
    
    override func initialize(kpiIndex: Int) {
        super.initialize(kpiIndex: kpiIndex)
        self.kpiText.text = kpiResult.value
        self.delegate?.kpiQuestSubViewNewHeight(self.frame.size.height)
    }
    
    override func getValuation () -> KpiResponseValues {
        var response = KpiResponseValues()
        response.value = self.kpiText.text!
        return response
    }
}

// MARK: - UITextFieldDelegate

extension SubText: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
