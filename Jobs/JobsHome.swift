//
//  Profile.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class JobsHome: MYViewController {
    class func Instance() -> JobsHome {
        return Instance(sbName: "Jobs", isInitial: true) as! JobsHome
    }

    @IBOutlet private var tableView: UITableView!
    private let wheel = MYWheel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MYJob.shared.job = Job()
        MYJob.shared.jobResult = JobResult()
        loadJobs()
    }
    
    override func headerViewDxTapped() {
        MYJob.shared.clearJobs()
        loadJobs()
    }
    
    private func loadJobs () {
        getList(done: { (array) in
            var jobsArray = [Job]()
            for dict in array {
                let job = MYJob.shared.createJob(withDict: dict)
                if job.id > 0 {
                    jobsArray.append(job)
                }
            }
            self.dataArray = jobsArray
            self.tableView.reloadData()
        })
    }
}

// MARK: - Job List

extension JobsHome {
    private func getList(done: @escaping  ([JsonDict]) -> () = { array in })  {
        let jobs = MYJob.shared.loadJobs()
        if jobs.count > 0 {
            done (jobs)
            return
        }

        User.shared.getUserToken(completion: {
            loadJobList()
        }) {
            (errorCode, message) in
            self.alert(errorCode, message: message, okBlock: nil)
        }
        
        func loadJobList () {
            let param = [ "object" : "jobs_list" ]
            let request = MYHttp.init(.get, param: param)
            request.load(ok: {
                (response) in
                done (response.array("jobs") as! [JsonDict])
            }) {
                (errorCode, message) in
                self.alert(errorCode, message: message, okBlock: nil)
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

//MARK: - JobsHomeCellDelegate

extension JobsHome: JobsHomeCellDelegate {
    func mapTapped(_ sender: JobsHomeCell, job: Job) {
        let store = job.store
        _ = Maps.init(lat: store.latitude,
                      lon: store.longitude,
                      name: store.name)
    }
}

// MARK: - Selected job

extension JobsHome {
    private func selectedJob (job: Job) {
        wheel.start(self.view)
        
        let loadJob = LoadJob()
        loadJob.delegate = self
        loadJob.selectedJob(job)
    }
}

extension JobsHome: LoadJobDelegate {
    func loadJobSuccess(_ loadJob: LoadJob) {
        wheel.stop()
        let vc = JobDetail.Instance()
        self.navigationController?.show(vc, sender: self)
    }

    func loadJobError(_ loadJob: LoadJob, errorCode: String, message: String) {
        wheel.stop()
        self.alert(errorCode, message: message, okBlock: nil)
    }
}


