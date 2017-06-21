//
//  ViewController.swift
//  MisteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

protocol MenuViewDelegate {
    func menuHide()
    func menuSelectedItem(item: Int)
}

class MenuView: UIView, UITableViewDelegate, UITableViewDataSource {
    class func Instance() -> MenuView {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! MenuView
    }

    var delegate: MenuViewDelegate?
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backView: UIView!
    
    private var dataArray = [String]()
    private let cellId = "MenuCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
        let tapBack = UITapGestureRecognizer.init(target: self, action: #selector(menuHide))
        self.backView.addGestureRecognizer(tapBack)
    }
    
    func loadData(items: [String]) {
        self.dataArray = items
    }
    
    func menuHide () {
        self.delegate?.menuHide()
    }
    
    // MARK: table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId,
                                                 for: indexPath) as UITableViewCell
        cell.textLabel?.text = self.dataArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.menuSelectedItem(item: indexPath.row)
    }
}

