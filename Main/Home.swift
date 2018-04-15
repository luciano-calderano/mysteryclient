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
        menuVisible(menuView.isHidden)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MYUpload.startUpload()
    }
}

extension Home: UITableViewDataSource {
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HomeCell.dequeue(tableView, indexPath)
        let item = dataArray[indexPath.row] as! MenuItem
        cell.title = item.type.rawValue
        return cell
    }
}

extension Home: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = dataArray[indexPath.row] as! MenuItem
        menuSelectedItem(item)
    }
}
//MARKK:- HomeCell - UITableViewCell

class HomeCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView, _ indexPath: IndexPath) -> HomeCell {
        return tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
    }

    var title = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBOutlet private var titleLabel: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.layer.cornerRadius = titleLabel.frame.size.height / 2
        titleLabel.layer.masksToBounds = true
        titleLabel.backgroundColor = .myGreenLight
        titleLabel.textColor = .white
    }
}

