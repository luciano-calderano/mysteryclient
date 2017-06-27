//
//  Incarichi.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

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
    
    var booked = 0 // Boolean [0/1]
        // Mandatory. Flag showing that the job it’s been booked. It should not be shown to the user.
    
    var booking_date: Date! // = "" //Date and Time [aaaa-mm-dd hh:mm:ss]
        // Mandatory. Date when the job it’s been booked. The label which is shown in the system is Data di prenotazione.
    
    var compiled = 0 // Boolean [0/1]
        // Mandatory. Flag showing that the job it’s been filled in. Should be automatically enhanced with 1 when the user finishes to fill the job in and the user label the job ready to be sent. It should not be shown to the user.
    
    var compilation_date: Date! //  = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time when the user fills in the job. The date should be populate automatically with the date and the time when the user fills in the job and label it ready to be sent. It should not be shown to the user.
    
    var updated = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the job it’s been updated from the user. Should be automatically enhanced with 1 when the user finishes to fill the job in and the user label the job ready to be sent only if the job was already been completed previously and sign like irregular. It should not be shown to the user.
    
    var update_date: Date? //  = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time whe the user updated the job. Should be automatically enhanced with Date and time when the user finishes to fill the job in and the user label the job ready to be sent only if the job was already been completed previously and sign like irregular. It should not be shown to the user.
    
    var validated = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the job it’s been validated. It should not be shown to the user.
    
    var validation_date: Date? //  = "" // Date and Time
        // Optional. Date and time when the job it’s been [aaaa-mm-dd validated. It should not be shown to the user.hh:mm:ss]
    
    var irregular = 0 // Boolean [0/1]
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

    var learning_done = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the user has completed learning for the job. If set to 0 you have to hide job compilation button and show instead a learning compilation button with the url is defined in learning_url. The url must be hidden for users.
    
    var learning_url = ""
        // Optional. Url to use to get the learning. The page must be open with the browser. At the end of compilation you have to reload jobs list. It should not be shown to the user.
    
    var store_closed = 0 // Boolean [0/1]
        //Mandatory. Flag showing if it is possible to perform the job. Default value is 0. If it is not possible to perform the job flag must be set to 1. In this case you have to ask for the reason, store it in the comment field and exit compile page. The label which is shown to the user is Sei riuscito a svolgere l’incarico? Should be possible to modify by the user
}

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

class Positioning  {
    var required = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the geolocation of the user is required at the beginning and at the end of the job. It should not be shown to the user.
    var start = 0 // Boolean [0/1]
        // Optional. Flag showing if the data to geolocate the user at the beginning of the job have been collected. Must the populate automatically when the user press Start. It should not be shown to the user.
    var start_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time the user press Start. It should not be shown to the user..
    var start_lat:Double = 0
        // Optional. Latitude where the user press Start. It should not be shown to the user.
    var start_lng:Double = 0
        // Optional. Longitude where the user press Start. It should not be shown to the user.
    var end = 0 // Boolean [0/1]
        // Optional. Flag showing the the data for the golocation of the user at the and of the job are been collected. Must be populate automatically when the user press Stop. It should not be shown to the user.

    var end_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time when the user press Stop. It should not be shown to the user.
    var end_lat:Double = 0
        // Optional. Latitude where the user press Stop. It should not be shown to the user.
    var end_lng:Double = 0
        // Optional. Longitude where the user press Stop. It should not be shown to the user.
}

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

    var required = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the answer to this Kpi is mandatory. It should not be shown to the user.

    var note_required = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the note is mandatory for this Kpi. It should not be shown to the user.
    var note_error_message = ""
        // Optional. Error Message to show to the user if the note is not filled in. To use only if the note is mandatory. It should not be shown to the user.
    
    var attachment = 0 // Boolean [0/1]
        // Mandatory. Flag showing if this Kpi require to insert the attachement from the user. It should not be shown to the user.

    var attachment_required = 0 // Boolean [0/1]
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
    
    var valuations = [Valutations]()
        // Optional. Array of Valuation type objects. Contains the possible answers the user can choose. The display of the answer depends from the Kpi Type.
    
    var result = Result()
        // Mandatory. Result type object. Contains the information the user insert related to the current answer. The data in the Object will be used to populate the answer already insert from the user in case the user want to complete or up
}

class Valutations {
    var id = 0
        // Mandatory. Valuation ID. It should not be shown to the user.
    
    var name = ""
        // Mandatory. Valuation name. Is the name show in the select or in the list used from the user to select the answers.
    
    var order = 0
        // Mandatory. Progressive order number of the valuation
    
    var positive = 0 // Boolean [0/1]
        // Mandatory. Flag showing is this valuation can be positve or negative. To be considered only if the Kpi has the flag section = 1. If the valuation is positive show the other Kpi in the same section, otherwise no. It should not be shown to the user.
    
    var note_required = 0 // Boolean [0/1]
        // Mandatory. Flag if the valution require a not from the user. It should not be shown to the user.
    
    var attachment_required = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the valuation requires an attachement from the user. It should not be shown to the user.
    
    var dependencies = [Dependency]()
        // Optional. Array of Dependency type objects. Contain actions activated from the answer to this section Essentially is necessary to enhance others Kpi or the respective notes.
}

class Dependency {
    var key = 0
        // Mandatory. Related kpi ID. Corresponds with the active Kpi only if the valuation selected require the cancellation of the note or to insert a specific note. It should not be shown to the user.
    
    var value = ""
        // Optional. Value to set up as value in the relative Kpi answer. It should not be shown to the user.
    
    var notes = ""
        // Optional. Value to set up as note in the relative Kpi answer. It should not be shown to the user.
}

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

