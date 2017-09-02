//
//  Profile.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class JobsHome: MYViewController {
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MYJob.shared.job = Job()
        MYJob.shared.jobResult = JobResult()
        
        let jobs = MYJob.shared.loadJobs()
        if jobs.count > 0 {
            self.jobs(jobs)
        }
        else {
            self.jobsDownload()
        }
    }
    
    override func headerViewDxTapped() {
        self.jobsDownload()
    }
    
    // MARK: - private
    
    private func jobsDownload () {
        User.shared.getUserToken(completion: {
            self.loadData()
        }) { (errorCode, message) in
            self.alert("Error: \(errorCode)", message: message, okBlock: nil)
        }
    }
    
    private func loadData() {
        let param = [
            "object" : "jobs",
            ]
        let request = MYHttp.init(.rest_get, param: param)
        
        request.load(ok: { (response) in
            self.jobs(response.array("jobs") as! [JsonDict])
        }) { (title, error) in
            self.alert(title, message: error, okBlock: nil)
        }
    }
    
    private func jobs (_ dict: [JsonDict]) {
        MYJob.shared.saveJobs(dict)
        let jobs = Jobs.init(withArray: dict)
        self.dataArray = jobs.jobList
        self.tableView.reloadData()
    }
    
    // MARK: - Dict -> Job Class
    
    class Jobs {
        var jobList = [Job]()
        
        init (withArray jobsArray: [JsonDict]) {
            for dict in jobsArray {
                let job = MYJob.shared.createJob(withDict: dict)
                if job.id > 0 {
                    self.jobList.append(job)
                }
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension JobsHome: UITableViewDataSource {
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = JobsHomeCell.dequeue(tableView, indexPath)
        cell.delegate = self
        cell.item(item: self.dataArray[indexPath.row] as! Job)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension JobsHome: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        MYJob.shared.job = self.dataArray[indexPath.row] as! Job
        MYResult.shared.loadResult (jobId: MYJob.shared.job.id)
        
        let vc = JobDetail.Instance()
        self.navigationController?.show(vc, sender: self)
    }
}

//MARK: - JobsHomeCellDelegate
extension JobsHome: JobsHomeCellDelegate {
    func mapTapped(_ sender: JobsHomeCell, job: Job) {
        let store = job.store
        _ = Maps.init(lat: store.latitude,
                      lon: store.longitude,
                      name: store.name)
    }
}

