//
//  JsonDictExtension.swift
//  Lc
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

extension UIViewController {
    class func InstanceFromSb (_ sb: String) -> UIViewController {
        let id = String (describing: self)
        let sb = UIStoryboard.init(name: sb, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: id)
        return vc
    }

    func alert (_ title:String, message: String, cancelBlock:((UIAlertAction) -> Void)?, okBlock:((UIAlertAction) -> Void)?) {
        
        let alert = UIAlertController(title: title as String, message: message as String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: cancelBlock))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okBlock))

        present(alert, animated: true, completion: nil)
    }

    func alert (_ title:String, message: String, okBlock:((UIAlertAction) -> Void)?) {
        
        let alert = UIAlertController(title: title as String, message: message  as String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okBlock))
        
        present(alert, animated: true, completion: nil)
    }
}

