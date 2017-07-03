//
//  KpiRadio.swift
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiRadio: UIView, UITableViewDelegate, UITableViewDataSource {
    class func Instance() -> KpiRadio {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! KpiRadio
    }
    
    var kpi = Kpi()
//    var delegate: KpiRadioDelegate?
    
    @IBOutlet private var tableView: UITableView!
    private let cellId = "cellId"
//    private let radioIco = UIImage.init(named: "ico.radioBtn")?.resize(16)
    private var indexPathSelected: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
    }
    
    @IBAction func okTapped () {
        self.removeFromSuperview()
    }
    
    func updateKpi (kpi: Kpi) {
        self.kpi = kpi
        self.tableView.reloadData()
    }
    
    // MARK: - table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.kpi.valuations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: self.cellId)
            cell?.imageView?.image = UIImage.init(named: "ico.radioBtn")?.resize(16)
        }
        
        let item = self.kpi.valuations[indexPath.row]
        
        cell?.imageView?.isHidden = !(indexPath == self.indexPathSelected)
        cell?.textLabel?.text = item.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.indexPathSelected = indexPath
        self.tableView.reloadData()
//        let item = self.job.attachments[indexPath.row]
//        print(item)
//        self.delegate?.openFileFromUrlWithString(item.url + "/" + item.filename)
    }
}
