//
//  HomeCell.swift
//  MysteryClient
//
//  Created by Lc on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

protocol JobsHomeCellDelegate {
    func mapTapped (job: Job)
}

class JobsHomeCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView,
                        _ indexPath: IndexPath) -> JobsHomeCell {
        let id = String (describing: self)
        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            as! JobsHomeCell
    }
    
    var job: Job!
    var delegate: JobsHomeCellDelegate?
    
    @IBOutlet fileprivate var name: MYLabel!
    @IBOutlet fileprivate var address: MYLabel!
    @IBOutlet fileprivate var rif: MYLabel!
    @IBOutlet fileprivate var day: MYLabel!
    @IBOutlet fileprivate var month: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func item (item: Job) {
        self.job = item
        self.name.text = self.job.store.name
        self.address.text = self.job.store.address
        self.rif.text = "Rif. " + self.job.reference
        self.day.text = self.job.estimate_date.toString(withFormat: "dd")
        self.month.text = self.job.estimate_date.toString(withFormat: "MMM")
    }
    
    @IBAction func mapTapped () {
        self.delegate?.mapTapped(job: self.job)
    }
}

