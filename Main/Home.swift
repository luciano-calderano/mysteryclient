//
//  ViewController.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Maps {
    init(job: Job) {
        if job.store.latitude == 0 || job.store.longitude == 0 {
            return
        }
        let name = job.store.name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let page = "ll=\(job.store.latitude),\(job.store.longitude)&q=" + name + "&z=10"
        let url = URL.init(string: Config.mapUrl + page)!
        UIApplication.shared.openURL(url)
    }
}

class Home: MYViewController, UITableViewDelegate, UITableViewDataSource, MenuViewDelegate {
    @IBOutlet private var tableView: UITableView!
    
    private var menuView = MenuView.Instance()
//    private var menuArray = [MenuItem]()
    
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
    
    override func headerViewSxTapped() {
        if self.menuView.isHidden == true {
            self.showMenu()
        }
        else {
            self.hideMenu()
        }
    }
    
    // MARK: - private
    
    private func loadData() {
        self.dataArray = [
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
    
    private func showMenu () {
        self.menuView.menuShow()
        self.headerTitle = Lng("menu")
        self.header?.header.sxButton.setImage(UIImage.init(named: "ico.back"), for: .normal)
    }
    
    private func hideMenu () {
        self.menuView.menuHide()
        self.headerTitle = Lng("home")
        self.header?.header.sxButton.setImage(UIImage.init(named: "ico.menu"), for: .normal)
    }
    
    private func selectedItem(_ item: MenuItem) {
        self.hideMenu()
        
        var webType = WebPage.WebPageEnum.none
        switch item.type {
        case .inca :
            let sb = UIStoryboard.init(name: "Jobs", bundle: nil)
            let ctrl = sb.instantiateInitialViewController()
            self.navigationController?.show(ctrl!, sender: self)
            return
        case .stor :
            ///////// Lc
            MYUpload.startUpload()
            return
//            webType = .storico
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
        self.navigationController?.show(ctrl, sender: self)
    }
    
    // MARK: - menu delegate
    
    func menuSelectedItem(_ item: MenuItem) {
        self.selectedItem(item)
    }
    
    func menuHide() {
        self.hideMenu()
    }
    
    // MARK: - table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HomeCell.dequeue(tableView, indexPath)
        let item = self.dataArray[indexPath.row] as! MenuItem
        cell.title = item.type.rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.dataArray[indexPath.row] as! MenuItem
        self.selectedItem(item)
    }
}
