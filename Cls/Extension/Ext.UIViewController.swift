//
//  JsonDictExtension.swift
//  Lc
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

extension UIViewController {
//    class func load (storyboard sbType: StoryboardType) -> UIViewController {
//        return self.load(storyboardName: sbType.rawValue)
//    }
    class func load (storyboardName: String) -> UIViewController {
        let vcName = String (describing: self)
        let sb = UIStoryboard.init(name: storyboardName, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: vcName)
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

