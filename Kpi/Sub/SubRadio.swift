//
//  KpiRadio.swift
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubRadio: KpiQuestSubView, UITableViewDelegate, UITableViewDataSource {
    class func Instance() -> SubRadio {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubRadio
    }

    @IBOutlet private var tableView: UITableView!
    private let rowHeight:CGFloat = 50
    private var valuationSelected: Job.Kpi.Valuations?

    override func awakeFromNib() {
        super.awakeFromNib()
        SubRadioCell.register(tableView: self.tableView)
    }
    
    override func initialize(kpiResult: JobResult.KpiResult, valuations: [Job.Kpi.Valuations]) {
        super.initialize(kpiResult: kpiResult, valuations: valuations)
        self.tableView.layer.borderColor = UIColor.lightGray.cgColor
        self.tableView.layer.borderWidth = 1
        
        if self.kpiResult.value.isEmpty == false {
            let index = Int(self.kpiResult.value)
            for item in self.valuations {
                if item.id == index {
                    self.valuationSelected = item
                    break
                }
            }
        }

        self.tableView.reloadData()

        var rect = self.frame
        rect.size.height = self.rowHeight * CGFloat(self.valuations.count)
        self.frame = rect
        self.delegate?.subViewResized(newHeight: rect.size.height)
    }

    override func getValuation () -> KpiResponseValues {
        var response = KpiResponseValues()
        if self.valuationSelected != nil {
            let item = self.valuationSelected!
            response.value = String(item.id)
        }
        return response
    }
    
    // MARK: - table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.valuations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SubRadioCell.dequeue(tableView, indexPath)
        let item = self.valuations[indexPath.row]
        cell.valuationTitle.text = item.name
        
        let selected = (self.valuationSelected != nil && self.valuationSelected?.id == item.id)
        cell.selectedView.isHidden = !selected
        cell.icoNote.isHidden = item.note_required == false
        cell.icoAtch.isHidden = item.attachment_required == false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.valuationSelected = self.valuations[indexPath.row]
        self.tableView.reloadData()
    }
}

// MARK: -

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

    @IBOutlet var icoNote: UIImageView!
    @IBOutlet var icoAtch: UIImageView!
    @IBOutlet var valuationTitle: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectView.layer.borderWidth = 1
        self.selectView.layer.borderColor = UIColor.lightGray.cgColor
        self.selectView.layer.cornerRadius = self.selectView.frame.height / 2
        self.selectedView.layer.cornerRadius = self.selectedView.frame.height / 2
    }
}


