//
//  Profile.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class IncarichiHome: MYViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let fileConfig  = UserDefaults.init(suiteName: "incarichi.save")

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        User.shared.getUserToken(completion: {
            self.loadData()
        }) { (errorCode, message) in
            self.alert("Error: \(errorCode)", message: message, okBlock: nil)
        }
    }

    // MARK: - private
    
    private func loadData() {
        let request = MYHttpRequest.get("rest/get")
    
        request.json = [
            "object" : "jobs",
        ]
        request.start() { (result, response) in
            let code = response.int("code")
            if code == 200 && response.string("status") == "ok" {
                let jobs = response.array("jobs") as! [JsonDict]
                self.fileConfig?.setValue(jobs, forKey: "jobs")
                self.dataArray = self.jobsWithArray(jobs)
            }
        }
    }
    
    private func jobsWithArray(_ jobsArray: [JsonDict]) -> [Job] {
        var jobs = [Job]()
        for dict in jobsArray {
            let job = Job()
            job.id = dict.int("id")
            job.reference = dict.string("reference")
            
            job.description = dict.string("description")
            job.additional_description = dict.string("additional_description")
            job.details = dict.string("details")
            job.start_date = dict.string("start_date") // [aaaa-mm-dd]
            job.end_date = dict.string("end_date") // [aaaa-mm-dd]
            job.estimate_date = dict.string("estimate_date") // [aaaa-mm-dd]
            
            job.fee_desc = dict.string("fee_desc")
            job.status = dict.string("status")
            job.booked = dict.int("booked") // Boolean [0/1]
            job.booking_date = dict.string("booking_date") // [aaaa-mm-dd hh:mm:ss]
            job.compiled = dict.int("compiled") // Boolean [0/1]
            job.compilation_date = dict.string("compilation_date") // [aaaa-mm-dd hh:mm:ss]
            job.updated = dict.int("updated") // Boolean [0/1]
            job.update_date = dict.string("update_date") // [aaaa-mm-dd hh:mm:ss]
            job.validated = dict.int("validated") // Boolean [0/1]
            job.validation_date = dict.string("validation_date") // and Time
            job.irregular = dict.int("irregular") // Boolean [0/1]
            job.notes = dict.string("notes")
            job.execution_date = dict.string("execution_date") // [aaaa-mm-dd]
            job.execution_start_time = dict.string("execution_start_time") // Time [hh:mm]
            job.execution_end_time = dict.string("execution_end_time") // Time [hh:mm]
            job.comment = dict.string("comment")
            job.learning_done = dict.int("learning_done") // Boolean [0/1]
            job.learning_url = dict.string("learning_url")
            job.store_closed = dict.int("store_closed") // Boolean [0/1]

            let store = dict.dictionary("store")
            job.store.name = store.string("name")
            job.store.type = store.string("type")
            job.store.address = store.string("address")
            job.store.latitude = store.double("latitude")
            job.store.longitude = store.double("longitude")

            let positioning = dict.dictionary("positioning")
            job.positioning.required = positioning.int("required") // Boolean [0/1]
            job.positioning.start = positioning.int("start") // Boolean [0/1]
            job.positioning.start_date = positioning.string("start_date") // [aaaa-mm-dd hh:mm:ss]
            job.positioning.start_lat = positioning.double("start_lat")
            job.positioning.start_lng = positioning.double("start_lng")
            job.positioning.end = positioning.int("required") // Boolean [0/1]
            job.positioning.end_date = positioning.string("end_date") // [aaaa-mm-dd hh:mm:ss]
            job.positioning.end_lat = positioning.double("end_lat")
            job.positioning.end_lng = positioning.double("end_lng")

            for attachment in dict.array("attachments") as! [JsonDict] {
                let att = Attachment()
                att.id = attachment.int("id")
                att.name = attachment.string("name")
                att.filename = attachment.string("filename")
                att.url = attachment.string("url")
                job.attachments.append(att)
            }
            for kpiDict in dict.array("kpis") as! [JsonDict] {
                let kpi = Kpi()
                kpi.id = kpiDict.int("id")
                kpi.name = kpiDict.string("name")
                kpi.section = kpiDict.int("section") //  Boolean [0/1]
                kpi.note = kpiDict.string("note")
                kpi.section_id = kpiDict.int("section_id")
                kpi.required = kpiDict.int("required") // Boolean [0/1]
                kpi.note_required = kpiDict.int("note_required") // Boolean [0/1]
                kpi.note_error_message = kpiDict.string("note_error_message")
                kpi.attachment = kpiDict.int("attachment") // Boolean [0/1]
                kpi.attachment_required = kpiDict.int("attachment_required") // Boolean [0/1]
                kpi.attachment_error_message = kpiDict.string("attachment_error_message")
                kpi.type = kpiDict.string("type")
                kpi.order = kpiDict.int("order")
                kpi.factor = kpiDict.string("factor")
                kpi.service = kpiDict.string("service")
                kpi.standard = kpiDict.string("standard")
                kpi.instructions = kpiDict.string("instructions")
                
                for valutation in kpiDict.array("valutation") as! [JsonDict] {
                    let val = Valutations()
                    val.id = valutation.int("id")
                    val.name = valutation.string("name")
                    val.order = valutation.int("order")
                    val.positive = valutation.int("positive") // Boolean [0/1]
                    val.note_required = valutation.int("note_required") // Boolean [0/1]
                    val.attachment_required = valutation.int("attachment_required") // Boolean [0/1]
                    for dependency in kpiDict.array("dependencies") as! [JsonDict] {
                        let dep = Dependency()
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
            jobs.append(job)
        }
        return jobs
    }
}
