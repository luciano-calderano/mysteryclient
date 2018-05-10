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
            do {
                try fm.createDirectory(atPath: workingPath,
                                       withIntermediateDirectories: true,
                                       attributes: nil)
            } catch let error as NSError {
                print("Unable to create directory \(error.debugDescription)")
            }
        }
        
        if MYJob.shared.jobResult.execution_date.isEmpty {
            getDetail ()
        } else {
            openJobDetail()
        }
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
            self.openJobDetail()
            
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
        
        if MYJob.shared.job.irregular == true {
        }
        reopenSentZip()

        self.delegate?.loadJobSuccess(self)
    }
    
    //MARK:- Irregular = true
    
    private func reopenSentZip () {
        let id = String(MYJob.shared.job.id)
        let file = MYZip.getZipFilePath(id: id)
        let sent = file.replacingOccurrences(of: Config.File.zipPefix, with: Config.File.zipSentPrefix)
        guard fm.fileExists(atPath: sent) else {
            return
        }
        
        let urlFile = URL.init(string: sent)!
        let urlDest = URL.init(string: workingPath)!
        MYZip.unzip(urlFile: urlFile, urlDest: urlDest)
        
        let dict = reloadJson()
        MYJob.shared.jobResult = MYResult.shared.resultWithDict(dict)
        try? fm.removeItem(atPath: sent)
    }
    
    private func reloadJson () -> JsonDict {
        let jsonFile = workingPath + Config.File.json
        let url = URL.init(fileURLWithPath: jsonFile)
        do {
            let data = try Data.init(contentsOf:url)
            return createJsonWithData(data)
        }
        catch let error as NSError {
            print("\nError reading data: \(error.localizedDescription)")
        }
        return JsonDict()
    }
    
    private func createJsonWithData (_ data: Data) -> JsonDict {
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as! JsonDict
            return dict
        } catch {
            print("\nJSONSerialization: \(error.localizedDescription)")
        }
        return JsonDict()
    }
}
