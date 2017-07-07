//
//  KpiRadio.swift
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubRadio: KpiPageSubView, UITableViewDelegate, UITableViewDataSource {
    class func Instance() -> SubRadio {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubRadio
    }

    @IBOutlet private var tableView: UITableView!
    private var indexSelected = 0
    private let rowHeight:CGFloat = 50
    
    override func awakeFromNib() {
        super.awakeFromNib()
        SubRadioCell.register(tableView: self.tableView)
    }
    
    override func initialize(kpiResult: JobResult.KpiResult, valuations: [Job.Kpi.Valuations]) {
        super.initialize(kpiResult: kpiResult, valuations: valuations)

        self.indexSelected = -1
        if self.kpiResult.value.isEmpty == false {
            self.indexSelected += 1
            let index = Int(self.kpiResult.value)
            for item in self.valuations {
                if item.id == index {
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
        cell.selectedView.isHidden = !(indexPath.row == self.indexSelected)
        cell.icoNote.isHidden = item.note_required == false
        cell.icoAtch.isHidden = item.attachment_required == false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.indexSelected = indexPath.row
        let item = self.valuations[indexPath.row]
        self.kpiResult.value = String(item.id)
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

    @IBOutlet var radioView: UIView!
    @IBOutlet var selectedView: UIView!

    @IBOutlet var icoNote: UIImageView!
    @IBOutlet var icoAtch: UIImageView!
    @IBOutlet var valuationTitle: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.radioView.layer.borderWidth = 1
        self.radioView.layer.borderColor = UIColor.black.cgColor
        self.radioView.layer.cornerRadius = self.radioView.frame.height / 2
        self.selectedView.layer.cornerRadius = self.selectedView.frame.height / 2
    }
}


