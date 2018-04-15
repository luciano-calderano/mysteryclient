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
    var headerTitle = "" {
        didSet { header?.header.titleLabel.text = headerTitle }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20))
        view.backgroundColor = UIColor.myGreenDark
        self.view.addSubview(view)
        self.view.backgroundColor = UIColor.white
        header?.delegate = self
        header?.header.kpiLabel.isHidden = true
//        if self.header?.header.dxButton.image(for: .normal) == nil {
//            self.header?.header.dxButton.isHidden = true
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        header?.header.kpiLabel.isHidden = true
    }
    
    func headerViewSxTapped() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func headerViewDxTapped() {
        assertionFailure("override dx button tap")
    }
}

class MenuViewController: MYViewController {
    let menuView = MenuView.Instance()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        
        var rect = self.view.frame
        rect.origin.x = -rect.size.width
        rect.origin.y = (self.header?.frame.origin.y)! + (self.header?.frame.size.height)!
        rect.size.height -= rect.origin.y
        menuView.frame = rect
        menuView.isHidden = true
        menuView.delegate = self
        self.view.addSubview(self.menuView)
    }

    private func loadData() {
        dataArray = [
            addMenuItem("ico.incarichi", type: .inca),
            addMenuItem("ico.ricInc",    type: .stor),
            addMenuItem("ico.profilo",   type: .prof),
            addMenuItem("ico.cercando",  type: .cerc),
            addMenuItem("ico.news",      type: .news),
            addMenuItem("ico.learning",  type: .lear),
        ]
    }
    
    private func addMenuItem (_ iconName: String, type: MenuItemEnum) -> MenuItem {
        let icon = UIImage.init(named: iconName)!
        let size = 24
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        icon.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let item = MenuItem.init(icon: newImage, type: type)
        return item
    }
    
    private func selectedItem(_ item: MenuItem) {
        menuHide()
        
        var webType = WebPage.WebPageEnum.none
        switch item.type {
        case .inca :
            let vc = JobsHome.Instance()
//            let sb = UIStoryboard.init(name: "Jobs", bundle: nil)
//            let ctrl = sb.instantiateInitialViewController()
            self.navigationController?.show(vc, sender: self)
            return
        case .stor :
            webType = .storico
        case .prof :
            webType = .profile
        case .cerc :
            webType = .cercando
        case .news :
            webType = .news
        case .cont :
            webType = .contattaci
        case .lear :
            webType = .learning
        case .logout :
            User.shared.logout()
            self.navigationController?.popToRootViewController(animated: true)
            return
        default:
            return
        }
        let ctrl = WebPage.Instance(type: webType)
//        UIApplication.shared.openURL(URL.init(string: ctrl.page)!)
        self.navigationController?.show(ctrl, sender: self)
    }

    //MARK: - Menu show/hode

    func menuHide() {
        menuView.menuHide()
        headerTitle = MYLng("home")
        header?.header.sxButton.setImage(UIImage.init(named: "ico.menu"), for: .normal)
    }
    
    func menuShow () {
        menuView.menuShow()
        headerTitle = MYLng("menu")
        header?.header.sxButton.setImage(UIImage.init(named: "ico.back"), for: .normal)
    }
}

extension MenuViewController: MenuViewDelegate {
    func menuSelectedItem(_ item: MenuItem) {
        selectedItem(item)
    }
    
    func menuVisible(_ visible: Bool) {
        if visible {
            menuShow()
        }
        else {
            menuHide()
        }
    }
}

