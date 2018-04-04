//
//  Ext.UIView.swift
//  Kanito
//
//  Created by mac on 17/03/17.
//  Copyright © 2017 Kanito. All rights reserved.
//

import UIKit

extension UIView {
    class func loadXib (xibName: String = "") -> Any {
        let viewName = xibName.isEmpty ? String (describing: self) : xibName
        let array = Bundle.main.loadNibNamed(viewName, owner: self, options: nil)
        return array!.first ?? UIView()
    }

    func addSubviewWithConstraints (_ view: UIView, edge: UIEdgeInsets = UIEdgeInsets.zero) {
        self.addSubview(view)
        self.costraintTo(view: view, atb: .top,     f: edge.top)
        self.costraintTo(view: view, atb: .left,    f: edge.left)
        self.costraintTo(view: view, atb: .bottom,  f: edge.bottom)
        self.costraintTo(view: view, atb: .right,   f: edge.right)
        if self is UIScrollView {
            self.costraintTo(view: view, atb: .centerX, f: 0)
            self.costraintTo(view: view, atb: .height, f: view.frame.size.height)
        }
    }

    func costraintTo (view: UIView, atb: NSLayoutAttribute, f: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let dest = (atb == .height || atb == .width) ? nil : self
        self.addConstraint (NSLayoutConstraint(item: view,
                                               attribute:   atb,
                                               relatedBy:   .equal,
                                               toItem:      dest,
                                               attribute:   atb,
                                               multiplier:  1,
                                               constant:    f))
    }
}

