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
        vc.job = job
        vc.jobResult = jobResult
        return vc
    }

    @IBOutlet private var tableView: UITableView!
    private let cellId = "cellId"

    var job: Job!
    var jobResult: JobResult!
    private var resultKeys = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        for result in self.jobResult.getResults() {
            self.resultKeys.append(self.jobResult.getKpiResultId(kpiResult: result))
        }
    }

    // MARK: - table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.job.kpis.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = KpisListCell.dequeue(tableView, indexPath)
        let item = self.job.kpis[indexPath.row]
        cell.item(item: item)
        cell.isDone(self.resultKeys.contains(item.id))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = KpisDetail.Instance(job: self.job, index: indexPath.row)
        self.navigationController?.show(vc, sender: self)
    }
}

class KpisListCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView,
                        _ indexPath: IndexPath) -> KpisListCell {
        let id = String (describing: self)
        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            as! KpisListCell
    }
    
    
    @IBOutlet private var num: MYLabel!
    @IBOutlet private var title: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.num.layer.cornerRadius = self.num.frame.size.height / 2
        self.num.layer.masksToBounds = true
    }
    
    func item (item: Kpi) {
        self.num.text = "" //  String(item.order)
        self.title.text = item.standard
    }
    
    func isDone(_ done: Bool) {
        self.num.backgroundColor = done == false ? UIColor.red : UIColor.myGreenDark
    }
}


