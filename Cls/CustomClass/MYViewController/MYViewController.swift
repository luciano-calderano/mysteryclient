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
//        if self.header?.header.dxButton.image(for: .normal) == nil {
//            self.header?.header.dxButton.isHidden = true
//        }
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

class MenuViewController: MYViewController {
    var menuView = MenuView.Instance()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        
        var rect = self.view.frame
        rect.origin.x = -rect.size.width
        rect.origin.y = (self.header?.frame.origin.y)! + (self.header?.frame.size.height)!
        rect.size.height -= rect.origin.y
        self.menuView.frame = rect
        self.menuView.isHidden = true
        self.menuView.delegate = self
        self.view.addSubview(self.menuView)
    }

    private func loadData() {
        dataArray = [
            self.addMenuItem("ico.incarichi", type: .inca),
            self.addMenuItem("ico.ricInc",    type: .stor),
            self.addMenuItem("ico.profilo",   type: .prof),
            self.addMenuItem("ico.cercando",  type: .cerc),
            self.addMenuItem("ico.news",      type: .news),
            self.addMenuItem("ico.learning",  type: .lear),
        ]
        
        //        self.menuArray = [
        //            self.addMenuItem("ico.home",      type: .home),
        //            self.addMenuItem("ico.incarichi", type: .inca),
        //            self.addMenuItem("ico.ricInc",    type: .stor),
        //            self.addMenuItem("ico.profilo",   type: .prof),
        //            self.addMenuItem("ico.cercando",  type: .cerc),
        //            self.addMenuItem("ico.news",      type: .news),
        //            self.addMenuItem("ico.mail",      type: .cont),
        //            self.addMenuItem("ico.logout",    type: .logout),
        //        ]
        //        self.menuView.loadData(items: self.menuArray)
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
    
    func selectedItem(_ item: MenuItem) {
        self.menuHide()
        
        var webType = WebPage.WebPageEnum.none
        switch item.type {
        case .inca :
            let sb = UIStoryboard.init(name: "Jobs", bundle: nil)
            let ctrl = sb.instantiateInitialViewController()
            self.navigationController?.show(ctrl!, sender: self)
            return
        case .stor :
//            ///////// Lc
//            MYUpload.startUpload()
//            return
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
        UIApplication.shared.openURL(URL.init(string: ctrl.page)!)

//        self.navigationController?.show(ctrl, sender: self)
    }

    //MARK: - Menu show/hode

    func menuHide() {
        self.menuView.menuHide()
        self.headerTitle = MYLng("home")
        self.header?.header.sxButton.setImage(UIImage.init(named: "ico.menu"), for: .normal)
    }
    
    func menuShow () {
        self.menuView.menuShow()
        self.headerTitle = MYLng("menu")
        self.header?.header.sxButton.setImage(UIImage.init(named: "ico.back"), for: .normal)
    }
}

extension MenuViewController: MenuViewDelegate {
    func menuSelectedItem(_ item: MenuItem) {
        selectedItem(item)
    }
    
    func menuVisible(_ visible: Bool) {
        if visible {
            self.menuShow()
        }
        else {
            self.menuHide()
        }
    }
}

