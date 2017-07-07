//
//  Ext.Image.swift
//  Kanito
//
//  Created by Luciano Calderano on 07/12/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(_ maxSize: CGFloat) -> UIImage? {
        let maxOrigSize = max(self.size.width, self.size.height)
        let diff = 1 / maxOrigSize * maxSize
        let newSize = CGSize.init(width: self.size.width * diff, height: self.size.height * diff)
        
        return self.resize(newSize: newSize)
    }
    
    func resize(newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale

        let newSize = CGSize.init(width: newWidth, height: newHeight)
        
        return self.resize(newSize: newSize)
//
//        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
//        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
//        
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage
    }
    
    func resize(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
