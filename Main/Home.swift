//
//  ViewController.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Home: MenuViewController {
    @IBOutlet private var tableView: UITableView!
    
    override func headerViewSxTapped() {
        self.menuVisible(self.menuView.isHidden)
    }
}

extension Home: UITableViewDataSource {
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
}

extension Home: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.dataArray[indexPath.row] as! MenuItem
        self.menuSelectedItem(item)
    }
}

