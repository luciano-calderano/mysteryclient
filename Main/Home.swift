//
//  ViewController.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Home: MYViewController, UITableViewDelegate, UITableViewDataSource, MenuViewDelegate {

    @IBOutlet private var tableView: UITableView!
    
    private var menuView = MenuView.Instance()
    private var menuArray = [MenuItem]()

    struct HomeItem {
        var type: HomeItemEnum
    }

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
            self.addHomeItem(type: .daComp),
            self.addHomeItem(type: .daConv),
            self.addHomeItem(type: .irrego),
            self.addHomeItem(type: .annull),
            self.addHomeItem(type: .inPaga),
            self.addHomeItem(type: .conclu),
            ]
//        self.dataArray = [
//            self.addMenuItem("ico.incarichi", type: .inca),
//            self.addMenuItem("ico.ricInc",    type: .rInc),
//            self.addMenuItem("ico.profilo",   type: .prof),
//            self.addMenuItem("ico.cercando",  type: .cerc),
//            self.addMenuItem("ico.news",      type: .news),
//            self.addMenuItem("ico.learning",  type: .lear),
//        ]
        
        self.menuArray = [
            self.addMenuItem("ico.home",      type: .home),
            self.addMenuItem("ico.incarichi", type: .inca),
            self.addMenuItem("ico.ricInc",    type: .rInc),
            self.addMenuItem("ico.profilo",   type: .prof),
            self.addMenuItem("ico.cercando",  type: .cerc),
            self.addMenuItem("ico.news",      type: .news),
            self.addMenuItem("ico.cont",      type: .cont),
            self.addMenuItem("ico.logout",    type: .logout),
        ]
        self.menuView.loadData(items: self.menuArray)
    }

    private func addHomeItem (type: HomeItemEnum) -> HomeItem {
        let item = HomeItem.init(type: type)
        return item
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
        self.menuView.isHidden = false
        self.header?.header.sxButton.setImage(UIImage.init(named: "ico.back"), for: .normal)
        self.header?.header.titleLabel.text = Lng("incarichi")
        UIView.animate(withDuration: 0.3) {
            var rect = self.menuView.frame
            rect.origin.x = 0
            self.menuView.frame = rect
        }
    }

    private func hideMenu () {
        self.header?.header.sxButton.setImage(UIImage.init(named: "ico.menu"), for: .normal)
        self.header?.header.titleLabel.text = Lng("home")
        UIView.animate(withDuration: 0.2, animations: {
            var rect = self.menuView.frame
            rect.origin.x = -rect.size.width
            self.menuView.frame = rect
        }) { (true) in
            self.menuView.isHidden = true
        }
    }
    
    private func selectedIMenutem(_ item: MenuItem) {
        self.hideMenu()
        switch item.type {
        case .inca :
            let sb = UIStoryboard.init(name: "Incarichi", bundle: nil)
            let ctrl = sb.instantiateInitialViewController()
            self.navigationController?.show(ctrl!, sender: self)
        case .prof :
            let ctrl = WebPage.Instance(type: .profile)
            self.navigationController?.show(ctrl, sender: self)
        case .logout :
            self.menuView.isHidden = true
            User.shared.logout()
            self.navigationController?.popToRootViewController(animated: true)
        default:
            return
        }
    }
    
    private func selectedHomeItem (_ item: HomeItem) {
    }
    
    // MARK: - menu delegate

    func menuselectedIMenutem(_ item: MenuItem) {
        self.selectedIMenutem(item)
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
        let item = self.dataArray[indexPath.row] as! HomeItem
        cell.title = item.type.rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.dataArray[indexPath.row] as! HomeItem
        self.selectedHomeItem(item)
    }
}
