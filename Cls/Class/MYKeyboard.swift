//
//  Keyboard.swift
//  MysteryClient
//
//  Created by mac on 10/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class MYKeyboard {
    private var scroll: UIScrollView!
    private var prevOffset = CGPoint.zero
    private var vc: UIViewController!
    private var h:CGFloat = 0
    init() {
        
    }
    init(vc: UIViewController) {
        self.vc = vc
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(notification:)),
                                               name:NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(notification:)),
                                               name:NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow (notification: NSNotification) {
        let kbSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        self.h = kbSize.cgRectValue.size.height
    }
    
    @objc func keyboardWillHide (notification: NSNotification) {
        if self.scroll != nil {
            self.scroll.contentInset = UIEdgeInsets.zero
        }
    }
    
    func endEditing() {
        self.scroll.contentOffset = self.prevOffset
    }
    
    func startEditing(scroll: UIScrollView, y: CGFloat) {
        self.scroll = scroll
        self.scroll.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: self.h, right: 0)
        
        self.prevOffset = self.scroll.contentOffset
        var offset = self.scroll.contentOffset
        offset.y = y
        self.scroll.contentOffset = offset
    }
    
}

