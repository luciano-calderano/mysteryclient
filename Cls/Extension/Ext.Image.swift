//
//  Ext.Image.swift
//  Kanito
//
//  Created by Luciano Calderano on 07/12/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(_ newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
