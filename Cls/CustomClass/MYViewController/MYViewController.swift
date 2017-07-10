//
//  MyViewController.swift
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class MYViewController: UIViewController, HeaderViewDelegate {
    @IBOutlet var header: HeaderContainerView?
    var dataArray = [Any]()
    var headerTitle: String {
        get { return (self.header?.header.titleLabel.text)! }
        set { self.header?.header.titleLabel.text = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20))
        view.backgroundColor = UIColor.myGreenDark
        self.view.addSubview(view)
        self.view.backgroundColor = UIColor.white
        self.header?.delegate = self
        if self.header?.header.dxButton.image(for: .normal) == nil {
            self.header?.header.dxButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.header?.header.kpiLabel.isHidden = true
    }
    
    func headerViewSxTapped() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func headerViewDxTapped() {
        assertionFailure("override dx button tap")
    }
}
