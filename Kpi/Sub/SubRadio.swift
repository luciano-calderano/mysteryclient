//
//  KpiRadio.swift
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubRadio: KpiQuestSubView {
    class func Instance() -> SubRadio {
        let id = "SubRadio"
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubRadio
    }
    
    @IBOutlet var tableView: UITableView!
    let rowHeight:CGFloat = 50
    var valuationSelected: Job.Kpi.Valuation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        SubRadioCell.register(tableView: tableView)
    }
    
    override func initialize(kpiIndex: Int) {
        super.initialize(kpiIndex: kpiIndex)
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1
        
        if self.kpiResult.value.isEmpty == false {
            let index = Int(self.kpiResult.value)
            for item in self.kpi.valuations {
                if item.id == index {
                    self.valuationSelected = item
                    break
                }
            }
        }
        
        
        tableView.reloadData()
        
        var rect = self.frame
        rect.size.height = self.rowHeight * CGFloat(self.kpi.valuations.count)
        self.frame = rect
        delegate?.kpiQuestSubViewNewHeight(rect.size.height)
    }
    
    override func getValuation () -> KpiResponseValues {
        var response = KpiResponseValues()
        if let item = valuationSelected {
            response.value = "\(item.id)"
            response.notesReq = item.note_required
            response.attchReq = item.attachment_required
            
            if item.dependencies.count > 0 {
                response.valuations = self.kpi.valuations
            }
        }
        return response
    }
}

// MARK: - UITableViewDataSource

extension SubRadio: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        valuationSelected = kpi.valuations[indexPath.row]
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension SubRadio: UITableViewDataSource {
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
        let cell = SubRadioCell.dequeue(tableView, indexPath)
        let item = self.kpi.valuations[indexPath.row]
        cell.valuationTitle.text = item.name
        
        let selected = (self.valuationSelected != nil && self.valuationSelected?.id == item.id)
        cell.selectedView.isHidden = !selected
        return cell
    }
}

// MARK: - SubRadioCell

class SubRadioCell: UITableViewCell {
    class func register (tableView: UITableView) {
        let id = String (describing: self)
        let nib = UINib(nibName: id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: id)
    }
    
    class func dequeue (_ tableView: UITableView,
                        _ indexPath: IndexPath) -> SubRadioCell {
        
        let id = String (describing: self)
        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            as! SubRadioCell
    }
    
    @IBOutlet var selectView: UIView!
    @IBOutlet var selectedView: UIView!
    @IBOutlet var valuationTitle: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectView.layer.borderWidth = 1
        self.selectView.layer.borderColor = UIColor.lightGray.cgColor
        self.selectView.layer.cornerRadius = self.selectView.frame.height / 2
        self.selectedView.layer.cornerRadius = self.selectedView.frame.height / 2
    }
}


