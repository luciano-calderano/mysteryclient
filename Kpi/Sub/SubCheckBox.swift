//
//  SubCheckBox.swift
//  MysteryClient
//
//  Created by mac on 12/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubCheckBox: KpiQuestSubView, UITableViewDelegate, UITableViewDataSource {
    class func Instance() -> SubCheckBox {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubCheckBox
    }
    
    @IBOutlet private var tableView: UITableView!
    private let rowHeight:CGFloat = 50
    private var selectedId = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.addSubviewWithConstraints(self.tableView)
        SubCheckBoxCell.register(tableView: self.tableView)
    }
    
    override func initialize(kpiIndex: Int) {
        super.initialize(kpiIndex: kpiIndex)
        self.tableView.layer.borderColor = UIColor.lightGray.cgColor
        self.tableView.layer.borderWidth = 1
        
        if self.kpiResult.value.isEmpty == false {
            let itemsId = self.kpiResult.value.components(separatedBy: ",")
            for item in self.kpi.valuations {
                let id = String(item.id)
                if itemsId.contains(id) {
                    self.selectedId.append(id)
                }
            }
        }
        
        self.tableView.reloadData()
        
        var rect = self.frame
        rect.size.height = self.rowHeight * CGFloat(self.kpi.valuations.count)
        self.frame = rect
        self.delegate?.subViewResized(newHeight: rect.size.height)
    }
    
    override func getValuation () -> KpiResponseValues {
        var response = KpiResponseValues()
        if self.selectedId.count > 0 {
            for item in self.kpi.valuations {
                let id = String(item.id)
                if self.selectedId.contains(id) {
                    if response.value.isEmpty == false {
                        response.value += ","
                    }
                    response.value += String(item.id)
                    if item.note_required == true {
                        response.notes = item.note_required
                    }
                    if item.attachment_required == true {
                        response.attch = item.attachment_required
                    }
                }
            }
        }
        return response
    }
    
    // MARK: - table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.kpi.valuations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SubCheckBoxCell.dequeue(tableView, indexPath)
        let item = self.kpi.valuations[indexPath.row]
        let id = String(item.id)
        let selected = self.selectedId.contains(id)

        cell.valuationTitle.text = item.name
        cell.icoCheck.isHidden = !selected
        cell.icoNote.isHidden = item.note_required == false
        cell.icoAtch.isHidden = item.attachment_required == false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.kpi.valuations[indexPath.row]
        let id = String(item.id)
        if self.selectedId.contains(id) {
            let idx = self.selectedId.index(of: id)
            self.selectedId.remove(at: idx!)
        }
        else {
            self.selectedId.append(id)
        }
        self.tableView.reloadData()
    }
}

// MARK: -

class SubCheckBoxCell: UITableViewCell {
    class func register (tableView: UITableView) {
        let id = String (describing: self)
        
        let nib = UINib(nibName: id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: id)
    }
    
    class func dequeue (_ tableView: UITableView,
                        _ indexPath: IndexPath) -> SubCheckBoxCell {
        
        let id = String (describing: self)
        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            as! SubCheckBoxCell
    }
    
    @IBOutlet var icoCheck: UIImageView!
    @IBOutlet var selectView: UIView!
    
    @IBOutlet var icoNote: UIImageView!
    @IBOutlet var icoAtch: UIImageView!
    @IBOutlet var valuationTitle: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectView.layer.borderWidth = 1
        self.selectView.layer.borderColor = UIColor.lightGray.cgColor
    }
}


