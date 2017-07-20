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
//    var kpiResult = JobResult.KpiResult()

    private let jobsPath = NSTemporaryDirectory() + "jobs"
    func saveJobs (_ jobs: [JsonDict]) {
        let fm = FileManager.default
        do {
            if fm.fileExists(atPath: self.jobsPath) {
                try FileManager.default.removeItem(atPath: self.jobsPath)
            }
            try fm.createDirectory(atPath: self.jobsPath,
                                   withIntermediateDirectories: true,
                                   attributes: nil)
        } catch let error as NSError {
            NSLog("Directory error: \(error.debugDescription)")
        }
        
        for dict in jobs {
            _ = dict.saveToFile(self.getFileName(id: dict.int("id")))
        }
    }
    
    func loadJobs() -> [JsonDict] {
        var jobs = [JsonDict]()
        let fm = FileManager.default
        
        do {
            let files = try fm.contentsOfDirectory(atPath: self.jobsPath)
            for file in files {
                let dict = JsonDict.init(fromFile: self.jobsPath + "/" + file)
                jobs.append(dict)
            }
        }
        catch {
            print("Error reading plist: \(error)")
        }
        return jobs
    }
    
    func removeJob () {
        do {
            try FileManager.default.removeItem(atPath: self.getFileName(id: MYJob.shared.job.id))
        } catch let error as NSError {
            NSLog("Remove error: \(error.debugDescription)")
        }
    }
    
    private func getFileName (id: Int) -> String {
        let fileName = self.jobsPath + "/" + String(id)  + ".plist"
        return fileName
    }
}
    ////////////////
    // MARK: - Result
    ////////////////
    
class MYResult {
    static let shared = MYResult()
    private let fileConfig  = UserDefaults.init(suiteName: "result")
    
    func getResultFromPlist () -> JsonDict {
        let resultFromPlist = self.fileConfig?.value(forKey: String(MYJob.shared.jobResult.id)) as? JsonDict
        if resultFromPlist != nil {
            return resultFromPlist!
        }
        return JsonDict()
    }
    
    func loadResult (jobId id: Int) {
        let result = MYJob.shared.jobResult

        result.id = id
        let dict = self.getResultFromPlist()
        if dict.isEmpty {
            return
        }
        result.id                     = dict.int("id")
        result.estimate_date          = dict.string("estimate_date")
        result.compiled               = dict.int("compiled")
        result.compilation_date       = dict.string("compilation_date")
        result.updated                = dict.int("updated")
        result.update_date            = dict.string("update_date")
        result.execution_date         = dict.string("execution_date")
        result.execution_start_time   = dict.string("execution_start_time")
        result.execution_end_time     = dict.string("execution_end_time")
        result.store_closed           = dict.int("store_closed")
        result.comment                = dict.string("comment")
        
        let pos = dict.dictionary("positioning")
        result.positioning.start      = pos.bool("start")
        result.positioning.start_date = pos.string("start_date")
        result.positioning.start_lat  = pos.double("start_lat")
        result.positioning.start_lng  = pos.double("start_lng")
        result.positioning.end        = pos.bool("end")
        result.positioning.end_date   = pos.string("end_date")
        result.positioning.end_lat    = pos.double("end_lat")
        result.positioning.end_lng    = pos.double("end_lng")
        
        for kpiDict in dict.array("results") as! [JsonDict] {
            let kpiResult = JobResult.KpiResult()
            kpiResult.kpi_id        = kpiDict.int("kpi_id")
            kpiResult.value         = kpiDict.string("value")
            kpiResult.notes         = kpiDict.string("notes")
            kpiResult.attachment    = kpiDict.string("attachment")
            result.results.append(kpiResult)
        }
        MYJob.shared.jobResult = result
    }
    
    
    func saveResult () {
        var resultArray = [JsonDict]()
        let result = MYJob.shared.jobResult
        
        for kpiResult in result.results {
            let dict:JsonDict = [
                "kpi_id"     : kpiResult.kpi_id,
                "value"      : kpiResult.value,
                "notes"      : kpiResult.notes,
                "attachment" : kpiResult.attachment,
                ]
            resultArray.append(dict)
        }
        
        let dictPos:JsonDict = [
            "start"      : result.positioning.start,
            "start_date" : result.positioning.start_date,
            "start_lat"  : result.positioning.start_lat,
            "start_lng"  : result.positioning.start_lng,
            "end"        : result.positioning.end,
            "end_date"   : result.positioning.end_date,
            "end_lat"    : result.positioning.end_lat,
            "end_lng"    : result.positioning.end_lng,
            ]
        
        let dict = [
            "id"                        : result.id,
            "estimate_date"             : result.estimate_date,
            "compiled"                  : result.compiled,
            "compilation_date"          : result.compilation_date,
            "updated"                   : result.updated,
            "update_date"               : result.update_date,
            "execution_date"            : result.execution_date,
            "execution_start_time"      : result.execution_start_time,
            "execution_end_time"        : result.execution_end_time,
            "store_closed"              : result.store_closed,
            "comment"                   : result.comment,
            "results"                   : resultArray,
            "positioning"               : dictPos
            ] as JsonDict
        
        self.fileConfig?.setValue(dict, forKey: String(result.id))
    }
    
    func sendResult () -> Bool{        
        let dict = self.getResultFromPlist()
        do {
            let fm = FileManager.default
            let path = NSTemporaryDirectory() + String(MYJob.shared.job.id)
            
            let json = try JSONSerialization.data(withJSONObject: dict,
                                                  options: .prettyPrinted)
            try? json.write(to: URL.init(string: path + "/json.txt")!)
            
            let files = try fm.contentsOfDirectory(at: URL.init(string: path)!,
                                                   includingPropertiesForKeys: nil,
                                                   options: [])
            let zipFile = URL.init(fileURLWithPath: path + ".zip")
            try Zip.zipFiles(paths: files,
                             zipFilePath: zipFile,
                             password: nil,
                             progress: nil)
            self.uploadFile(zipFile)
        } catch {
            return false
        }
        return true
    }

    func uploadFile (_ zipFile: URL) {
        var data: Data!
        do {
            data = try Data.init(contentsOf: zipFile, options: .mappedIfSafe)
        } catch {
            return
        }
        let request = MYHttpRequest("rest/put")
        
        request.json = [
            "object"        : "job",
            "object_id"     : MYJob.shared.job.id,
            "object_file"   : data,
        ]
        
        request.put(data: data) { (success, response) in
            if success {
//                do {
//                    try FileManager.default.removeItem(atPath: zipFile.absoluteString)
//                }
//                catch {
//                    
//                }
            }
        }

    }
    
}

class Job {
    var id = 0
        //Mandatory. Job ID. It should not be shown to the user.
    
    var reference = ""
        //Mandatory. It is the name used to identify the job in the communications with the user. The label which is shown in the system Riferimento.

    var store = Store()
        // Mandatory. Object di Type Store. Contains the information about the store checked
    
    var description = ""
        // Mandatory. Description of te job. The label which is shown in the system Descrizione incarico.
    
    var additional_description = ""
        // Optional. Additional description of the job. It is used to give to the user more details. Show to the user only if the user is enhanced. The label which is shown in the system Descrizione aggiuntiva.
    
    var details = ""
        // Mandatory. Detail of the time the job can be done. The label which is shown in the system Può essere eseguito.
    
    var start_date: Date! // = "" // Date [aaaa-mm-dd]
        // Mandatory. Date from when the visit can be done. It should not be shown to the user.
    
    var end_date: Date! //  = "" // Date [aaaa-mm-dd]
        // Mandatory. Date within the job can be done. It should [aaaa-mm-dd] not be shown to the user..
    
    var estimate_date: Date! //  = "" // Date [aaaa-mm-dd]
        //Date Mandatory. Date the user likes to do the job. The label [aaaa-mm-dd] which is shown in the system Data stimata di esecuzione.
    
    var fee_desc = ""
        // Mandatory. Description of the fee to do the job. The label which is shown in the system Descrizione compenso.
    
    var status = ""
        // Mandatory. Status of the job. The label which is shown in the system Stato.
    
    var booked = false
        // Mandatory. Flag showing that the job it’s been booked. It should not be shown to the user.
    
    var booking_date: Date! // = "" //Date and Time [aaaa-mm-dd hh:mm:ss]
        // Mandatory. Date when the job it’s been booked. The label which is shown in the system is Data di prenotazione.
    
    var compiled = false
        // Mandatory. Flag showing that the job it’s been filled in. Should be automatically enhanced with 1 when the user finishes to fill the job in and the user label the job ready to be sent. It should not be shown to the user.
    
    var compilation_date: Date! //  = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time when the user fills in the job. The date should be populate automatically with the date and the time when the user fills in the job and label it ready to be sent. It should not be shown to the user.
    
    var updated = false
        // Mandatory. Flag showing if the job it’s been updated from the user. Should be automatically enhanced with 1 when the user finishes to fill the job in and the user label the job ready to be sent only if the job was already been completed previously and sign like irregular. It should not be shown to the user.
    
    var update_date: Date? //  = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time whe the user updated the job. Should be automatically enhanced with Date and time when the user finishes to fill the job in and the user label the job ready to be sent only if the job was already been completed previously and sign like irregular. It should not be shown to the user.
    
    var validated = false
        // Mandatory. Flag showing if the job it’s been validated. It should not be shown to the user.
    
    var validation_date: Date? //  = "" // Date and Time
        // Optional. Date and time when the job it’s been [aaaa-mm-dd validated. It should not be shown to the user.hh:mm:ss]
    
    var irregular = false
        // Mandatory. Flag showing is the job it’s been labeled like irregular. It should not be shown to the user.
    
    var notes = ""
        // Optional. Note to show to the user if it is necessary to regulate the job. Usually populate if the job is irregular to explain the motive. The label which is shown in thesystem is Note.
    
    var positioning = Positioning() // Object
        // Mandatory. Object of type Positioning. Contains the information to geolocate the beginning and the end of the job.
    
    var execution_date: Date? //  = "" // Date [aaaa-mm-dd]
        // Optional. Date when the user has done the job. Must [aaaa-mm-dd] be the same date of the execution. If a different date is insert is necessary to say to the user to move the date before the job is filled in. The label which is shown in the system is Date di esecuzione. Should be possible to modify by the user
    
    var execution_start_time = "" // Time [hh:mm]
        // Optional. Time the user started the job. The label which is shown to the user is Ora inizio esecuzione. Should be possible to modify by the user
    
    var execution_end_time = "" // Time [hh:mm]
        // Optional. Time the user finished the job. The label which is shown to the user is Ora fine esecuzione. Should be possible to modify by the user
    
    var comment = ""
    // Optional. Final comment made from the user. The label which is shown to the user is Commento. Should be possible to modify by the user
    
    var attachments = [Attachment]()
        // Optional. Array of Attachment type objects. Contains links to documents to attach.
    
    var kpis = [Kpi]()
        // Mandatory. Array of Kpi type objects. Contains questions the user must answer.

    var learning_done = false
        // Mandatory. Flag showing if the user has completed learning for the job. If set to 0 you have to hide job compilation button and show instead a learning compilation button with the url is defined in learning_url. The url must be hidden for users.
    
    var learning_url = ""
        // Optional. Url to use to get the learning. The page must be open with the browser. At the end of compilation you have to reload jobs list. It should not be shown to the user.
    
    var store_closed = false
        //Mandatory. Flag showing if it is possible to perform the job. Default value is 0. If it is not possible to perform the job flag must be set to 1. In this case you have to ask for the reason, store it in the comment field and exit compile page. The label which is shown to the user is Sei riuscito a svolgere l’incarico? Should be possible to modify by the user

    //MARK: -
    
    class Store {
        var name = ""
        // Mandatory. Store name. The label which is shown to the user is Punto vendita.
        var type = ""
        // Mandatory. It is the store type of the store to check. The label which is shown to the user is Type.
        var address = ""
        // Mandatory. Store address. Must be showed with the store name.
        var latitude: Double = 0 // Numeric
        // Optional. Store latitude. If available must be used to locate the store in the map. It should not be shown to the user.
        var longitude: Double = 0
        // Optional. Store longitude. If available must be used to locate the store in the map. It should not be shown to the user.
    }
    
    //MARK: -
    
    class Attachment {
        var id = 0
        // Mandatory. Attachment ID. It should not be shown to the user.
        var filename = ""
        // Mandatory. Name of the file saved on the user device.
        var name = ""
        // Mandatory. Description of the attached file. Must be used to prepare the link or button to download the file.
        var url = ""
        // Mandatory. Url to call to download the file. The Url is already completed and does not require any modification. It should not be shown to the user.
    }

    //MARK: -
    
    class Positioning  {
        var required = false
        // Mandatory. Flag showing if the geolocation of the user is required at the beginning and at the end of the job. It should not be shown to the user.
        var start = false
        // Optional. Flag showing if the data to geolocate the user at the beginning of the job have been collected. Must the populate automatically when the user press Start. It should not be shown to the user.
        var start_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time the user press Start. It should not be shown to the user..
        var start_lat:Double = 0
        // Optional. Latitude where the user press Start. It should not be shown to the user.
        var start_lng:Double = 0
        // Optional. Longitude where the user press Start. It should not be shown to the user.
        var end = false
        // Optional. Flag showing the the data for the golocation of the user at the and of the job are been collected. Must be populate automatically when the user press Stop. It should not be shown to the user.
        
        var end_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time when the user press Stop. It should not be shown to the user.
        var end_lat:Double = 0
        // Optional. Latitude where the user press Stop. It should not be shown to the user.
        var end_lng:Double = 0
        // Optional. Longitude where the user press Stop. It should not be shown to the user.
    }
    
    //MARK: -

    class Kpi {
        var id = 0
        // Mandatory. Kpi ID. It should not be shown to the user.
        var name = ""
        // Mandatory. Kpi Name. It should not be shown to the user.
        var section = 0 //  Boolean [0/1]
        // Mandatory. Flag to show that the Kpi contains the main question of a specific section. It should not be shown to the user.
        var note = ""
        // Optional. Message to use if the section cannot the completed. If the answer to the question of this kpi is negative the notes of all the other questions in the same section must have the same message. Populate only if section = 1. It should not be shown to the user..
        
        var section_id = 0
        // Optional. Kpi section: show this kpi only if the kpi that has section = 1 has a postiive answer. It should not be shown to the user.
        
        var required = false
        // Mandatory. Flag showing if the answer to this Kpi is mandatory. It should not be shown to the user.
        
        var note_required = false
        // Mandatory. Flag showing if the note is mandatory for this Kpi. It should not be shown to the user.
        var note_error_message = ""
        // Optional. Error Message to show to the user if the note is not filled in. To use only if the note is mandatory. It should not be shown to the user.
        
        var attachment = false
        // Mandatory. Flag showing if this Kpi require to insert the attachement from the user. It should not be shown to the user.
        
        var attachment_required = false
        // Mandatory. Flag showing if it is mandatory to insert an attachement for this kpi. This kpi must the verified only if the Kpi require to insert an attachment. It should not be shown to the user.
        
        var attachment_error_message = ""
        // Optional. Messaggio di errore da mostrare all'utente se non viene inserito l'allegato. Da utilizzare solamente se l'allegato è richiesto. It should not be shown to the user.
        
        var type = ""
        // Optional. Show the Type of answer expected and identify the Type of control to show at the user. “date”: The user must insert a date. The user can use a calendar. The format for the date is yyyy-mm- dd.
        // “datetime”: The user must insert a date completed with time. The user can use a calendar that has the possibility to select also the time. The format for the date is è yyyy-mm-dd hh:mm:ss.
        // “label”: The user cannot insert the information for this queation. It is used only to give information. “multicheckbox”: the user can select one o more answer within the proposed answers.
        // “radio”: The user can select only one answer among the proposed answer. The selection is made from a list.
        // “select”: the user can select only an answer among the proposed answers. The selection is made from a select.
        // “text”: the user can fill in a text camp to insert the answer.
        // “time”: the user must insert a timeo. It is possible to select the time from a selector. The format used from the system is hh:mm.
        //  It should not be shown to the user.
        
        var order = 0
        // Mandatory. Progressive order number of the question.
        
        var factor = ""
        // Mandatory. Name of the Kpi’s factor
        
        var service = ""
        // Mandatory. Nome of the Kpi’s service.
        
        var standard = ""
        // Mandatory. Question to be answer from the user.
        
        var instructions = ""
        // Optional. Additional instruction to fill in the job. Must be show after the question only if present.
        
        var valuations = [Valuations]()
        // Optional. Array of Valuation type objects. Contains the possible answers the user can choose. The display of the answer depends from the Kpi Type.
        
        var result = Result()
        // Mandatory. Result type object. Contains the information the user insert related to the current answer. The data in the Object will be used to populate the answer already insert from the user in case the user want to complete or up
        
        class Result {
            var id = 0
            // Optional. Answer id. It should not be shown to the user.
            
            var value = ""
            // Optional. The valuation given by the user to the Kpi. Depending of a kpi the value could be text or valuation id (separated from ;). Should be enhanced with the answer given from the user at the kpi question. The label which is shown to the user is Valutazione.
            
            var notes = ""
            // Optional. The note insert by the user to give additional details on the answer if necessary. The label which is shown to the user is Note.
            
            var attachment = ""
            // Optional. File mane attached to the answer. Is present only if the Kpi require to insert an attachment. The label which is shown to the user is Allegato.
            
            var url = ""
            // Optional. Url to call to download the file. The call is already completed and does not require any modification. It should not be shown to the user.
        }
        
        class Valuations {
            var id = 0
            // Mandatory. Valuation ID. It should not be shown to the user.
            
            var name = ""
            // Mandatory. Valuation name. Is the name show in the select or in the list used from the user to select the answers.
            
            var order = 0
            // Mandatory. Progressive order number of the valuation
            
            var positive = false
            // Mandatory. Flag showing is this valuation can be positve or negative. To be considered only if the Kpi has the flag section = 1. If the valuation is positive show the other Kpi in the same section, otherwise no. It should not be shown to the user.
            
            var note_required = false
            // Mandatory. Flag if the valution require a not from the user. It should not be shown to the user.
            
            var attachment_required = false
            // Mandatory. Flag showing if the valuation requires an attachement from the user. It should not be shown to the user.
            
            var dependencies = [Dependency]()
            // Optional. Array of Dependency type objects. Contain actions activated from the answer to this section Essentially is necessary to enhance others Kpi or the respective notes.
            class Dependency {
                var key = 0
                // Mandatory. Related kpi ID. Corresponds with the active Kpi only if the valuation selected require the cancellation of the note or to insert a specific note. It should not be shown to the user.
                
                var value = ""
                // Optional. Value to set up as value in the relative Kpi answer. It should not be shown to the user.
                
                var notes = ""
                // Optional. Value to set up as note in the relative Kpi answer. It should not be shown to the user.
            }
        }
    }
}

//MARK: - Result
//MARK: -

class JobResult {
    static let shared = JobResult()
    var id = 0
        // Mandatory. Job ID
    var estimate_date = "" // Date [aaaa-mm-dd]
        // Mandatory. Date the user would like to do the job.
    var compiled = 0 // Boolean [0/1]
        // Mandatory. Flag if the job it’s been completed from the user. Must be enhanced automatically with 1 when the user finish to fill in the job and label the job ready to be sent.
    var compilation_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Mandatory. Date and time when the user filled in the job. The date should be populate automatically with the date and the time when the user fills in the job and label it ready to be sent.
    var updated = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the job it’s been updated from the user. Must be enhanced automatically with 1 when the user completed the job and label it to be sent only if the job was already completed and labeled like irregular.
    var update_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time the user updated the job. Must be populate automatically with date and time when the user completed the update and label the job like ready to be sent only if the job was previously competed and labeled like irregular.
    var execution_date = "" // Date [aaaa-mm-dd]
        // Mandatory. Date when the user executed the job. Must correspond with the estimated date for the execution. Id the date is different must inform the user to modify the date before the compilation.
    var execution_start_time = "" // Time [hh:mm]
        //Mandatory. Time the user started the job.
    var execution_end_time = "" // Time [hh:mm]
        // Mandatory. Time the user finished the job.
    var store_closed = 0 // Boolean [0/1]
        // Mandatory. Flag showing if it is possible to perform the job. Default value is 0. If it is not possible to perform the job flag must be set to 1. In this case you have to ask for the reason, store it in the comment field and exit compile page. The label which is shown to the user is Sei riuscito a svolgere l’incarico? Should be possible to modify by the user
    var comment = ""
        // Mandatory. Final comment from the user.
    var results = [KpiResult]() // Array
        // Mandatory. Array of Result type objects. Must contain the user’s answers.
    var positioning = PositioningResult()
        // Mandatory. Object of type Positioning. Contains the information to geolocate the beginning and the end of the job.
 
    class KpiResult {
        var kpi_id = 0
        //Mandatory. Kpi ID.
        var value = ""
        // Optional. The valuation the user gave to kpi. Depending of a kpi the value coul be text or valuation id (separated with ,). Is mandatory only if specified by kpi settings.
        var notes = ""
        // Optional. The note the user insert to give additional details to the answer (when necessary). Is mandatory only if indicated in the kpi settings.
        var attachment = ""
        // Optional. Name of the t file attached to the answer. Is present only if the kpi require to insert the attachment. Is mandatory only if indicated in the settings of the related kpi’s. the name indicated in the filed must be the same of the file insert in the .zip file.
        // Note: All the attachment present in the object Result must be insert in the file (.zip) that contains the file scheme (job.json).
    }
    
    //MARK: -
    
    class PositioningResult  {
        var start = false
        // Optional. Flag showing if the data to geolocate the user at the beginning of the job have been collected. Must the populate automatically when the user press Start. It should not be shown to the user.
        var start_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time the user press Start. It should not be shown to the user..
        var start_lat:Double = 0
        // Optional. Latitude where the user press Start. It should not be shown to the user.
        var start_lng:Double = 0
        // Optional. Longitude where the user press Start. It should not be shown to the user.
        var end = false
        // Optional. Flag showing the the data for the golocation of the user at the and of the job are been collected. Must be populate automatically when the user press Stop. It should not be shown to the user.
        var end_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time the user press end. It should not be shown to the user..
        var end_lat:Double = 0
        // Optional. Latitude where the user press end. It should not be shown to the user.
        var end_lng:Double = 0
        // Optional. Longitude where the user press end. It should not be shown to the user.
    }
    
//
//    private let fileConfig  = UserDefaults.init(suiteName: "result")
//
//    func getDict () -> JsonDict {
//        var dict = JsonDict()
//        let resultFromPlist = self.fileConfig?.value(forKey: String(self.id)) as? JsonDict
//        if resultFromPlist != nil {
//            dict = resultFromPlist!
//        }
//        return dict
//    }
//    
//    func load (id: Int) {
//        self.id = id
//        let dict = self.getDict()
//        if dict.isEmpty {
//            return
//        }
//        self.id                     = dict.int("id")
//        self.estimate_date          = dict.string("estimate_date")
//        self.compiled               = dict.int("compiled")
//        self.compilation_date       = dict.string("compilation_date")
//        self.updated                = dict.int("updated")
//        self.update_date            = dict.string("update_date")
//        self.execution_date         = dict.string("execution_date")
//        self.execution_start_time   = dict.string("execution_start_time")
//        self.execution_end_time     = dict.string("execution_end_time")
//        self.store_closed           = dict.int("store_closed")
//        self.comment                = dict.string("comment")
//        
//        let pos = dict.dictionary("positioning")
//        self.positioning.start      = pos.bool("start")
//        self.positioning.start_date = pos.string("start_date")
//        self.positioning.start_lat  = pos.double("start_lat")
//        self.positioning.start_lng  = pos.double("start_lng")
//        self.positioning.end        = pos.bool("end")
//        self.positioning.end_date   = pos.string("end_date")
//        self.positioning.end_lat    = pos.double("end_lat")
//        self.positioning.end_lng    = pos.double("end_lng")
//        
//        for kpiDict in dict.array("results") as! [JsonDict] {
//            let kpiResult = KpiResult()
//            kpiResult.kpi_id        = kpiDict.int("kpi_id")
//            kpiResult.value         = kpiDict.string("value")
//            kpiResult.notes         = kpiDict.string("notes")
//            kpiResult.attachment    = kpiDict.string("attachment")
//            self.results.append(kpiResult)
//        }
//    }
//    
//
//    func save () {
//        var resultArray = [JsonDict]()
//        for kpiResult in self.results {
//            let dict:JsonDict = [
//                    "kpi_id"     : kpiResult.kpi_id,
//                    "value"      : kpiResult.value,
//                    "notes"      : kpiResult.notes,
//                    "attachment" : kpiResult.attachment,
//                ]
//            resultArray.append(dict)
//        }
//        
//        let dictPos:JsonDict = [
//            "start"      : self.positioning.start,
//            "start_date" : self.positioning.start_date,
//            "start_lat"  : self.positioning.start_lat,
//            "start_lng"  : self.positioning.start_lng,
//            "end"        : self.positioning.end,
//            "end_date"   : self.positioning.end_date,
//            "end_lat"    : self.positioning.end_lat,
//            "end_lng"    : self.positioning.end_lng,
//            ]
//
//        let dict = [
//            "id"                        : self.id,
//            "estimate_date"             : self.estimate_date,
//            "compiled"                  : self.compiled,
//            "compilation_date"          : self.compilation_date,
//            "updated"                   : self.updated,
//            "update_date"               : self.update_date,
//            "execution_date"            : self.execution_date,
//            "execution_start_time"      : self.execution_start_time,
//            "execution_end_time"        : self.execution_end_time,
//            "store_closed"              : self.store_closed,
//            "comment"                   : self.comment,
//            "results"                   : resultArray,
//            "positioning"               : dictPos
//        ] as JsonDict
//        
//        self.fileConfig?.setValue(dict, forKey: String(self.id))
//    }
}
