//
//  JobDetailDesc.swift
//  MysteryClient
//
//  Created by mac on 28/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class JobDetailDesc: UIView {
    class func Instance() -> JobDetailDesc {
        return InstanceView() as! JobDetailDesc
    }
    
    @IBOutlet var jobDesc: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var desc = MYJob.shared.job.description
        if MYJob.shared.job.additional_description.isEmpty == false {
            desc += "\n\n- Descrizione aggiuntiva\n\n" + MYJob.shared.job.additional_description + "\n\n"
        }
        if MYJob.shared.job.details.isEmpty == false {
            desc += "\n\n- Dettagli orario\n\n" + MYJob.shared.job.details + "\n\n"
        }
        jobDesc.text = desc
    }
    
    @IBAction func okTapped () {
        self.removeFromSuperview()
    }
}
