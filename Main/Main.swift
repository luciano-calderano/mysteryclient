//
//  ViewController.swift
//  MisteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Main: MYViewController, UITableViewDelegate, UITableViewDataSource, MenuViewDelegate {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var menuButton: MYButton!
    
    private var menuView = MenuView.Instance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        
        var rect = self.view.frame
        rect.origin.x = -rect.size.width
        self.menuView.frame = rect
        self.menuView.isHidden = true
        self.menuView.delegate = self
        self.view.addSubview(self.menuView)
    }
    
    private func loadData() {
        self.dataArray = [
            "Riga 1",
            "Riga 2",
            "Riga 3",
            "Riga 4",
            "Riga 5",
            "Riga 6",
            "Riga 7",
        ]
    }
    
    @IBAction func menuTapped () {
        self.showMenu()
    }
    
    private func showMenu () {
        self.menuView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            var rect = self.menuView.frame
            rect.origin.x = 0
            self.menuView.frame = rect
        }
    }
    
    private func hideMenu () {
        UIView.animate(withDuration: 0.2, animations: {
            var rect = self.menuView.frame
            rect.origin.x = -rect.size.width
            self.menuView.frame = rect
        }) { (true) in
            self.menuView.isHidden = true
        }
    }
    
    // MARK: menu delegate
    
    func menuSelectedItem(item: Int) {
        self.hideMenu()
    }
    
    func menuHide() {
        self.hideMenu()
    }
    
    // MARK: table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MainCell.dequeue(tableView, indexPath)
        cell.title = self.dataArray[indexPath.row] as! String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath.row)
    }
}

