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
    
    @IBAction func okTapped () {
        self.removeFromSuperview()
    }
}
