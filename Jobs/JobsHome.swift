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
            jobsListWithArray(jobs)
        }
        else {
            jobsDownload()
        }
    }
    
    override func headerViewDxTapped() {
        MYJob.shared.clearJobs()
        jobsDownload()
    }
}


// MARK: - Job List

extension JobsHome {
    private func jobsDownload () {
        User.shared.getUserToken(completion: {
            download()
        }) { (errorCode, message) in
            self.alert("Error: \(errorCode)", message: message, okBlock: nil)
        }
        
        func download() {
            let param = [ "object" : "jobs_list" ]
            let request = MYHttp.init(.get, param: param)
            
            request.load(ok: { (response) in
                self.jobsListWithArray(response.array("jobs") as! [JsonDict])
            }) { (title, error) in
                self.alert(title, message: error, okBlock: nil)
            }
        }
    }
    
    private func jobsListWithArray (_ dictArray: [JsonDict]) {
        var jobsArray = [Job]()        
        for dict in dictArray {
            let job = MYJob.shared.createJob(withDict: dict)
            if job.id > 0 {
                jobsArray.append(job)
            }
        }
        dataArray = jobsArray
        tableView.reloadData()
    }
}

//MARK: - UITableViewDataSource

extension JobsHome: UITableViewDataSource {
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = JobsHomeCell.dequeue(tableView, indexPath)
        cell.delegate = self
        cell.job =  dataArray[indexPath.row] as! Job
        return cell
    }
}

//MARK: - UITableViewDelegate

extension JobsHome: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedJob(job: dataArray[indexPath.row] as! Job)
    }
}

// MARK: - Selected job

extension JobsHome {
    private func selectedJob (job: Job) {
        
        func getDetail () {
            User.shared.getUserToken(completion: {
                loadJobKpis()
            }) { (errorCode, message) in
                self.alert("Error: \(errorCode)", message: message, okBlock: nil)
            }
            
            func loadJobKpis () {
                let job = MYJob.shared.job
                let param = [ "object" : "job", "object_id":  job.id ] as JsonDict
                let request = MYHttp.init(.get, param: param)
                
                request.load(ok: { (response) in
                    let dict = response.dictionary("job")
                    MYJob.shared.job = MYJob.shared.createJob(withDict: dict)
                    self.openJobDetail()
                    
                }) { (title, error) in
                    self.alert(title, message: error, okBlock: nil)
                }
            }
        }
        
        MYJob.shared.job = job
        MYJob.shared.invalidDependecies.removeAll()
        MYJob.shared.kpiKeyList.removeAll()
        for kpi in MYJob.shared.job.kpis {
            MYJob.shared.kpiKeyList.append(kpi.id)
        }
        MYJob.shared.jobResult = MYResult.shared.loadResult (jobId: MYJob.shared.job.id)

        if MYJob.shared.jobResult.execution_date.isEmpty {
            getDetail ()
        } else {
            openJobDetail()
        }
    }
    private func openJobDetail () {
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

