//
//  Incarichi.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import Zip

class MYJob {
    static let shared = MYJob()

    var job = Job()
    var jobResult = JobResult()
    var invalidDependecies = [String]()
    var kpiKeyList = [Int]()

    func saveJobs (_ jobs: [JsonDict]) {
        let fm = FileManager.default
        do {
            if fm.fileExists(atPath: Config.jobsPath) {
                try FileManager.default.removeItem(atPath: Config.jobsPath)
            }
            try fm.createDirectory(atPath: Config.jobsPath,
                                   withIntermediateDirectories: true,
                                   attributes: nil)
        } catch let error as NSError {
            print("Directory error: \(error.debugDescription)")
        }
        
        for dict in jobs {
            _ = dict.saveToFile(self.getFileName(id: dict.int("id")))
        }
    }
    
    func loadJobs() -> [JsonDict] {
        var jobs = [JsonDict]()
        let fm = FileManager.default
        
        do {
            let files = try fm.contentsOfDirectory(atPath: Config.jobsPath)
            for file in files {
                let array = file.components(separatedBy: ".") //Lc
                if array.count != 2 {
                    continue
                }
                if array[1] != "plist" {
                    continue
                }
                let dict = JsonDict.init(fromFile: Config.jobsPath + file)
                jobs.append(dict)
            }
        }
        catch {
            print("Error reading plist: \(error)")
        }
        return jobs
    }
    
    func removeJobWithId (_ id: Int) {
        do {
            try FileManager.default.removeItem(atPath: self.getFileName(id: id))
        } catch let error as NSError {
            print("Remove error: \(error.debugDescription)")
        }
    }
    
    func createJob(withDict dict: JsonDict) -> Job {
        var job = Job()
        job.compiled = dict.bool("compiled")    // Boolean [0/1]
        job.irregular = dict.bool("irregular")  // Boolean [0/1]
        job.updated = dict.bool("updated")      // Boolean [0/1]
        
        if job.compiled == true {
            if job.irregular == false || job.updated == true {
                return job
            }
        }
        //            compiled = false
        //            compiled = true & irregular = true & updated = false
        //            print(job.compiled, job.irregular, job.updated)
        
        job.id = dict.int("id")
        job.reference = dict.string("reference")
        
        job.description = dict.string("description")
        job.additional_description = dict.string("additional_description")
        job.details = dict.string("details")
        job.start_date = dict.date("start_date", fmt: Date.fmtDataJson)
        job.end_date = dict.date("end_date", fmt: Date.fmtDataJson)
        job.estimate_date = dict.date("estimate_date", fmt: Date.fmtDataJson)
        
        job.fee_desc = dict.string("fee_desc")
        job.status = dict.string("status")
        job.booked = dict.bool("booked") // Boolean [0/1]
        job.booking_date = dict.date("booking_date", fmt: Date.fmtDataOraJson)
        job.compilation_date = dict.date("compilation_date", fmt: Date.fmtDataOraJson)
        job.update_date = dict.date("update_date", fmt: Date.fmtDataOraJson)
        job.validated = dict.bool("validated") // Boolean [0/1]
        job.validation_date = dict.date("validation_date", fmt: Date.fmtDataOraJson)
        job.notes = dict.string("notes")
        job.execution_date = dict.date("execution_date", fmt: Date.fmtDataJson)
        job.execution_start_time = dict.string("execution_start_time") // Time [hh:mm]
        job.execution_end_time = dict.string("execution_end_time") // Time [hh:mm]
        job.comment = dict.string("comment")
        job.learning_done = dict.bool("learning_done") // Boolean [0/1]
        job.learning_url = dict.string("learning_url")
        job.store_closed = dict.bool("store_closed") // Boolean [0/1]
        
        let store = dict.dictionary("store")
        job.store.name = store.string("name")
        job.store.type = store.string("type")
        job.store.address = store.string("address")
        job.store.latitude = store.double("latitude")
        job.store.longitude = store.double("longitude")
        
        let positioning = dict.dictionary("positioning")
        job.positioning.required = positioning.bool("required") // Boolean [0/1]
        job.positioning.start = positioning.bool("start") // Boolean [0/1]
        job.positioning.start_date = positioning.string("start_date") // [aaaa-mm-dd hh:mm:ss]
        job.positioning.start_lat = positioning.double("start_lat")
        job.positioning.start_lng = positioning.double("start_lng")
        job.positioning.end = positioning.bool("required") // Boolean [0/1]
        job.positioning.end_date = positioning.string("end_date") // [aaaa-mm-dd hh:mm:ss]
        job.positioning.end_lat = positioning.double("end_lat")
        job.positioning.end_lng = positioning.double("end_lng")
        
        for attachment in dict.array("attachments") as! [JsonDict] {
            let att = Job.Attachment()
            att.id = attachment.int("id")
            att.name = attachment.string("name")
            att.filename = attachment.string("filename")
            att.url = attachment.string("url")
            job.attachments.append(att)
        }
        for kpiDict in dict.array("kpis") as! [JsonDict] {
            let kpi = Job.Kpi()
            kpi.id = kpiDict.int("id")
            kpi.name = kpiDict.string("name")
            kpi.section = kpiDict.int("section") //  Boolean [0/1]
            kpi.note = kpiDict.string("note")
            kpi.section_id = kpiDict.int("section_id")
            kpi.required = kpiDict.bool("required") // Boolean [0/1]
            kpi.note_required = kpiDict.bool("note_required") // Boolean [0/1]
            kpi.note_error_message = kpiDict.string("note_error_message")
            kpi.attachment = kpiDict.bool("attachment") // Boolean [0/1]
            kpi.attachment_required = kpiDict.bool("attachment_required") // Boolean [0/1]
            kpi.attachment_error_message = kpiDict.string("attachment_error_message")
            kpi.type = kpiDict.string("type")
            kpi.order = kpiDict.int("order")
            kpi.factor = kpiDict.string("factor")
            kpi.service = kpiDict.string("service")
            kpi.standard = kpiDict.string("standard")
            kpi.instructions = kpiDict.string("instructions")
            
            for valutation in kpiDict.array("valuations") as! [JsonDict] {
                let val = Job.Kpi.Valuation()
                val.id = valutation.int("id")
                val.name = valutation.string("name")
                val.order = valutation.int("order")
                val.positive = valutation.bool("positive") // Boolean [0/1]
                val.note_required = valutation.bool("note_required") // Boolean [0/1]
                val.attachment_required = valutation.bool("attachment_required") // Boolean [0/1]
                for dependency in valutation.array("dependencies") as! [JsonDict] {
                    let dep = Job.Kpi.Valuation.Dependency()
                    dep.key = dependency.int("key")
                    dep.value = dependency.string("value")
                    dep.notes = dependency.string("notes")
                    val.dependencies.append(dep)
                }
                kpi.valuations.append(val)
            }
            
            let result = kpiDict.dictionary("result")
            kpi.result.id = result.int("id")
            kpi.result.value = result.string("value")
            kpi.result.notes = result.string("notes")
            kpi.result.attachment = result.string("attachment")
            kpi.result.url = result.string("url")
            
            job.kpis.append(kpi)
        }
        return job
    }
    
    private func getFileName (id: Int) -> String {
        let fileName = Config.jobsPath + String(id) + Config.plist
        return fileName
    }
}
