//
//  SubCheckBox.swift
//  MysteryClient
//
//  Created by mac on 12/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class SubCheckBox: KpiQuestSubView {
    class func Instance() -> SubCheckBox {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! SubCheckBox
    }
    private let separator = ","
    
    @IBOutlet var tableView: UITableView!
    let rowHeight:CGFloat = 50
    var selectedId = [String]()
    
    // MARK:-
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1
        addSubviewWithConstraints(tableView)
        SubCheckBoxCell.register(tableView: tableView)
    }
    
    override func initialize(kpiIndex: Int) {
        super.initialize(kpiIndex: kpiIndex)
        
        if kpiResult.value.isEmpty == false {
            let itemsId = kpiResult.value.components(separatedBy: separator)
            for item in kpi.valuations {
                let id = String(item.id)
                if itemsId.contains(id) {
                    selectedId.append(id)
                }
            }
        }
        
        tableView.reloadData()
        
        var rect = frame
        rect.size.height = rowHeight * CGFloat(kpi.valuations.count)
        frame = rect
        delegate?.kpiQuestSubViewNewHeight(rect.size.height)
    }
    
    override func getValuation () -> KpiResponseValues {
        var response = KpiResponseValues()
        if selectedId.count > 0 {
            for item in kpi.valuations {
                let id = String(item.id)
                if selectedId.contains(id) {
                    if response.value.isEmpty == false {
                        response.value += separator
                    }
                    response.value += String(item.id)
                    if item.note_required == true {
                        response.notesReq = item.note_required
                    }
                    if item.attachment_required == true {
                        response.attchReq = item.attachment_required
                    }
                }
            }
        }
        return response
    }
}

//MARK:- UITableViewDataSource

extension SubCheckBox: UITableViewDataSource {
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kpi.valuations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SubCheckBoxCell.dequeue(tableView, indexPath)
        let item = kpi.valuations[indexPath.row]
        let id = String(item.id)
        let selected = selectedId.contains(id)
        
        cell.valuationTitle.text = item.name
        cell.icoCheck.isHidden = !selected
        return cell
    }
}

//MARK:- UITableViewDelegate

extension SubCheckBox: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = kpi.valuations[indexPath.row]
        let id = String(item.id)
        if selectedId.contains(id) {
            let idx = selectedId.index(of: id)
            selectedId.remove(at: idx!)
        }
        else {
            selectedId.append(id)
        }
        tableView.reloadData()
    }
}

//MARK:- SubCheckBoxCell

class SubCheckBoxCell: UITableViewCell {
    class func register (tableView: UITableView) {
        let id = String (describing: self)
        
        let nib = UINib(nibName: id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: id)
    }
    
    class func dequeue (_ tableView: UITableView,
                        _ indexPath: IndexPath) -> SubCheckBoxCell {
        
        let id = "SubCheckBoxCell"
        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            as! SubCheckBoxCell
    }
    
    @IBOutlet var icoCheck: UIImageView!
    @IBOutlet var selectView: UIView!    
    @IBOutlet var valuationTitle: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectView.layer.borderWidth = 1
        selectView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
