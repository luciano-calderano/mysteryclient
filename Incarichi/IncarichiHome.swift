//
//  Profile.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class IncarichiHome: MYViewController {
    
    @IBOutlet private inc.tableView: UITableView!
    
    private let fileConfig  = UserDefaults.init(suiteName: "incarichi.save")

    override func viewDidLoad() {
        super.viewDidLoad()
        User.shared.getUserToken(completion: { 
            self.loadData()
        }) { (errorNum, msg) in
            
        }
        self.loadData()
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
                let jobs = response.array("jobs")
                self.fileConfig?.setValue(jobs, forKey: "jobs")
            }
        }
    }
    
    private func jobs(jobs: [JsonDict]) {
        for dict in jobs {
            let inc = Incarichi()
            inc.id = dict.int("id")
            inc.reference = dict.string("reference")
            
            inc.description = dict.string("description")
            inc.additional_description = dict.string("additional_description")
            inc.details = dict.string("details")
            inc.start_date = dict.string("start_date") // Date [aaaa-mm-dd]
            inc.end_date = dict.string("end_date") // Date [aaaa-mm-dd]
            inc.estimate_date = dict.string("estimate_date") // Date [aaaa-mm-dd]
            
            inc.fee_desc = dict.string("fee_desc")
            inc.status = dict.string("status")
            inc.booked = dict.int("booked") // Boolean [0/1]
            inc.booking_date = dict.string("booking_date") //Date and Time [aaaa-mm-dd hh:mm:ss]
            inc.compiled = dict.int("compiled") // Boolean [0/1]
            inc.compilation_date = dict.string("compilation_date") // Date and Time [aaaa-mm-dd hh:mm:ss]
            inc.updated = dict.int("updated") // Boolean [0/1]
            inc.update_date = dict.string("update_date") // Date and Time [aaaa-mm-dd hh:mm:ss]
            inc.validated = dict.int("validated") // Boolean [0/1]
            inc.validation_date = dict.string("validation_date") // Date and Time
            inc.irregular = dict.int("irregular") // Boolean [0/1]
            inc.notes = dict.string("notes")
            inc.execution_date = dict.string("execution_date") // Date [aaaa-mm-dd]
            inc.execution_start_time = dict.string("execution_start_time") // Time [hh:mm]
            inc.execution_end_time = dict.string("execution_end_time") // Time [hh:mm]
            inc.comment = dict.string("comment")
            inc.learning_done = dict.int("learning_done") // Boolean [0/1]
            inc.learning_url = dict.string("learning_url")
            inc.store_closed = dict.int("store_closed") // Boolean [0/1]

            inc.store = Store()
            inc.positioning = Positioning()
            inc.attachments = [Attachment]()
            inc.kpis = [Kpi]()

        }
    }

}
