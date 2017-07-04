//
//  KpiRadio.swift
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpiRadio: KpiSubView, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    class func Instance() -> KpiRadio {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! KpiRadio
    }
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var tableViewHeight: NSLayoutConstraint!
    @IBOutlet private var kpiTitle: MYLabel!
    @IBOutlet private var kpiNote: UITextView!

    private var attachmentPath = ""
    private var indexSelected = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.kpiNote.text = ""
        self.kpiNote.delegate = self
        self.kpiNote.layer.borderColor = UIColor.lightGray.cgColor
        self.kpiNote.layer.borderWidth = 1
        
        KpiRadioCell.register(tableView: self.tableView)
    }
    
    override func updateKpi (kpi: Kpi) {
        super.updateKpi(kpi: kpi)
        self.kpiTitle.text = kpi.standard
        self.tableViewHeight.constant = self.tableView.rowHeight * CGFloat(self.kpi.valuations.count)
        self.tableView.reloadData()
    }
    
    override func checkResult() -> Bool {
        let item = self.kpi.valuations[self.indexSelected]
        if item.attachment_required == true {
            if self.attachmentPath.isEmpty {
                return false
            }
        }
        if item.note_required == true {
            if self.kpiNote.text.isEmpty {
                return false
            }
        }
        return true
    }
    
    //MARK: - text view delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.subViewStartEditing(y: self.kpiNote.frame.origin.y - 30)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            self.delegate?.subViewEndEditing()
            return false
        }
        return true
    }

    // MARK: - table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.kpi.valuations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = KpiRadioCell.dequeue(tableView, indexPath)
        let item = self.kpi.valuations[indexPath.row]
        cell.valuationTitle.text = item.name
        cell.selectedView.isHidden = !(indexPath.row == self.indexSelected)
        cell.icoNote.isHidden = item.note_required == false
        cell.icoAtch.isHidden = item.attachment_required == false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.indexSelected = indexPath.row
        self.tableView.reloadData()
    }
}

// MARK: -

class KpiRadioCell: UITableViewCell {
    class func register (tableView: UITableView) {
        let id = String (describing: self)

        let nib = UINib(nibName: id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: id)
    }
    
    class func dequeue (_ tableView: UITableView,
                        _ indexPath: IndexPath) -> KpiRadioCell {
        
        let id = String (describing: self)
        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            as! KpiRadioCell
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


