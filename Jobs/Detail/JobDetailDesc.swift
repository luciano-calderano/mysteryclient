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
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! JobDetailDesc
    }
    
    @IBOutlet var jobDesc: UITextView!
    
    @IBAction func okTapped () {
        self.removeFromSuperview()
    }
}
