//
//  SubText
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubText: KpiBaseSubView {
    class func Instance() -> SubText {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubText
    }

    @IBOutlet private var kpiText: MYTextField!

    override var kpiResult: JobResult.KpiResult? {
        didSet {
            kpiText.text = kpiResult?.value
            delegate?.kpiViewHeight(self.frame.size.height)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        kpiText.delegate = self
        kpiText.text = ""
    }
    
    override func getValuation () -> KpiResponseValues {
        var response = KpiResponseValues()
        response.value = kpiText.text!
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
