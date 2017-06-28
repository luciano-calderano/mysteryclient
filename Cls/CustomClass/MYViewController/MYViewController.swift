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
        self.view.backgroundColor = UIColor.myGreenDark
        self.header?.delegate = self
        if self.header?.header.dxButton.image(for: .normal) == nil {
            self.header?.header.dxButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func headerViewSxTapped() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func headerViewDxTapped() {
        assertionFailure("override dx button tap")
    }
}
