//
//  LoadJob.swift
//  MysteryClient
//
//  Created by Lc on 10/05/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

protocol LoadJobDelegate {
    func loadJobSuccess(_ loadJob: LoadJob)
    func loadJobError(_ loadJob: LoadJob, errorCode: String, message: String)
}

import Foundation

class LoadJob {
    var delegate: LoadJobDelegate?
    private var workingPath = ""
    private let fm = FileManager.default
    
    func selectedJob (_ job: Job) {
        MYJob.shared.job = job
        MYJob.shared.jobResult = MYResult.shared.loadResult (jobId: MYJob.shared.job.id)
        
        workingPath = Config.Path.doc + "\(MYJob.shared.job.id)"
        
        if fm.fileExists(atPath: workingPath) == false {
            if craateWorkingParh() {
                return
            }
        }
        
        if MYJob.shared.job.kpis.count == 0 {
            getDetail ()
        } else {
            openJobDetail()
        }
    }
    
    private func craateWorkingParh() -> Bool {
        do {
            try fm.createDirectory(atPath: workingPath,
                                   withIntermediateDirectories: true,
                                   attributes: nil)
        } catch let error as NSError {
            self.delegate?.loadJobError(self, errorCode: "Unable to create directory", message: error.debugDescription)
            return true
        }
        return false
    }
    
    private func getDetail () {
        User.shared.getUserToken(completion: {
            self.loadJobDetail()
        }) {
            (errorCode, message) in
            self.delegate?.loadJobError(self, errorCode: errorCode, message: message)
        }
    }
    
    private func loadJobDetail () {
        let job = MYJob.shared.job
        let param = [ "object" : "job", "object_id":  job.id ] as JsonDict
        let request = MYHttp.init(.get, param: param)
        
        request.load(ok: {
            (response) in
            let dict = response.dictionary("job")
            MYJob.shared.job = MYJob.shared.createJob(withDict: dict)
            if MYJob.shared.job.irregular == true {
                self.downloadResult()
            } else {
                self.openJobDetail()
            }
            
        }) {
            (errorCode, message) in
            self.delegate?.loadJobError(self, errorCode: errorCode, message: message)
        }
    }
    
    private func openJobDetail () {
        MYJob.shared.kpiKeyList.removeAll()
        for kpi in MYJob.shared.job.kpis {
            kpi.isValid = true
            MYJob.shared.kpiKeyList.append(kpi.id)
        }
        
        self.delegate?.loadJobSuccess(self)
    }
    
    //MARK:- Irregular = true
    
    private func downloadResult () {
        for kpi in MYJob.shared.job.kpis {
            let kpiResult = kpi.result
            let result = JobResult.KpiResult()
            result.kpi_id = kpiResult.id
            result.value = kpiResult.value
            result.notes = kpiResult.notes
            result.attachment = kpiResult.attachment
            MYJob.shared.jobResult.results.append(result)
            if kpiResult.url.isEmpty == false {
                downloadAtch(url: kpiResult.url, kpiId: kpi.id)
            }
        }
        openJobDetail()
    }

    private func downloadAtch (url urlString: String, kpiId: Int) {
        let job = MYJob.shared.job
        let param = [ "object" : "job", "result_attachment":  job.id ] as JsonDict
        let request = MYHttp.init(.get, param: param, showWheel: false)
        
        request.loadAtch(url: urlString, ok: {
            (response) in
            let dest = self.workingPath + "/\(MYJob.shared.job.reference).\(kpiId).jpg"
            do {
                try response.write(to: URL.init(string: "file://" + dest)!)
            } catch {
                print("Unable to load data: \(error)")
            }
        })
    }
}
