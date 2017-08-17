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

class Home: MenuViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func headerViewSxTapped() {
        self.menuVisible(self.menuView.isHidden)
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
        self.menuSelectedItem(item)
    }
}
