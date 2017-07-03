//
//  KpisList.swift
//  MysteryClient
//
//  Created by mac on 03/07/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class KpisList: MYViewController, UITableViewDelegate, UITableViewDataSource {
    class func Instance(job: Job, jobResult: JobResult) -> KpisList {
        let vc = self.load(storyboardName: "Jobs") as! KpisList
        vc.dataArray = job.kpis
        vc.jobResult = jobResult
        return vc
    }

    @IBOutlet private var tableView: UITableView!
    private let cellId = "cellId"

    var jobResult: JobResult!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
    }

    // MARK: - table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: self.cellId)
        }
        
        let item = self.dataArray[indexPath.row] as! Kpi
        cell?.imageView?.image = UIImage.init(named: "ico.download")?.resize(16)
        cell?.textLabel?.text = item.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class KpisListCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView,
                        _ indexPath: IndexPath) -> KpisListCell {
        let id = String (describing: self)
        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            as! KpisListCell
    }
    
    
    @IBOutlet fileprivate var num: MYLabel!
    @IBOutlet fileprivate var title: MYLabel!
    @IBOutlet fileprivate var checkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func item (item: Kpi) {
        self.num.text = String(item.order)
        self.title.text = item.name
        self.checkImage.isHidden = item.required
    }
}


