//
//  ViewController.swift
//  MysteryClient
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
    
    private var dataArray = [MenuItem]()
    private let cellId = "MenuCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
        let tapBack = UITapGestureRecognizer.init(target: self, action: #selector(menuHide))
        self.backView.addGestureRecognizer(tapBack)
    }
    
    func loadData(items: [MenuItem]) {
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
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId,
                                                 for: indexPath) as UITableViewCell
        let item = self.dataArray[indexPath.row]
        cell.imageView!.image = item.icon
        cell.textLabel?.text = item.type.rawValue
        cell.textLabel?.font = UIFont.size(14)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.menuSelectedItem(item: indexPath.row)
    }
}

