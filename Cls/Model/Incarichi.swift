//
//  Incarichi.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation

class Incarichi {
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
    var start_date = "" // Date [aaaa-mm-dd]
        // Mandatory. Date from when the visit can be done. It should not be shown to the user.
    var end_date = "" // Date [aaaa-mm-dd]
        // Mandatory. Date within the job can be done. It should [aaaa-mm-dd] not be shown to the user..
    var estimate_date = "" // Date [aaaa-mm-dd]
        //Date Mandatory. Date the user likes to do the job. The label [aaaa-mm-dd] which is shown in the system Data stimata di esecuzione.
    var fee_desc = ""
        // Mandatory. Description of the fee to do the job. The label which is shown in the system Descrizione compenso.
    var status = ""
        // Mandatory. Status of the job. The label which is shown in the system Stato.
    var booked = 0 // Boolean [0/1]
        // Mandatory. Flag showing that the job it’s been booked. It should not be shown to the user.
    var booking_date = "" //Date and Time [aaaa-mm-dd hh:mm:ss]
        // Mandatory. Date when the job it’s been booked. The label which is shown in the system is Data di prenotazione.
    var compiled = 0 // Boolean [0/1]
        // Mandatory. Flag showing that the job it’s been filled in. Should be automatically enhanced with 1 when the user finishes to fill the job in and the user label the job ready to be sent. It should not be shown to the user.
    var compilation_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time when the user fills in the job. The date should be populate automatically with the date and the time when the user fills in the job and label it ready to be sent. It should not be shown to the user.
    var updated = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the job it’s been updated from the user. Should be automatically enhanced with 1 when the user finishes to fill the job in and the user label the job ready to be sent only if the job was already been completed previously and sign like irregular. It should not be shown to the user.
    var update_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time whe the user updated the job. Should be automatically enhanced with Date and time when the user finishes to fill the job in and the user label the job ready to be sent only if the job was already been completed previously and sign like irregular. It should not be shown to the user.
    var validated = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the job it’s been validated. It should not be shown to the user.
    var validation_date = "" // Date and Time
        // Optional. Date and time when the job it’s been [aaaa-mm-dd validated. It should not be shown to the user.hh:mm:ss]
    var irregular = 0 // Boolean [0/1]
        // Mandatory. Flag showing is the job it’s been labeled like irregular. It should not be shown to the user.
    var notes = ""
        // Optional. Note to show to the user if it is necessary to regulate the job. Usually populate if the job is irregular to explain the motive. The label which is shown in thesystem is Note.
    var positioning = "" // Object
        // Mandatory. Object of type Positioning. Contains the information to geolocate the beginning and the end of the job.
    var execution_date = "" // Date [aaaa-mm-dd]
        // Optional. Date when the user has done the job. Must [aaaa-mm-dd] be the same date of the execution. If a different date is insert is necessary to say to the user to move the date before the job is filled in. The label which is shown in the system is Date di esecuzione. Should be possible to modify by the user
    var execution_start_time = "" // Time [hh:mm]
        // Optional. Time the user started the job. The label which is shown to the user is Ora inizio esecuzione. Should be possible to modify by the user
    var execution_end_time = "" // Time [hh:mm]
        // Optional. Time the user finished the job. The label which is shown to the user is Ora fine esecuzione. Should be possible to modify by the user
    var comment = ""
    // Optional. Final comment made from the user. The label which is shown to the user is Commento. Should be possible to modify by the user
    
    var attachments = [String]()
        // Optional. Array of Attachment type objects. Contains links to documents to attach.
    var kpis = [String]()
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
    var latitude: Float = 0 // Numeric
        // Optional. Store latitude. If available must be used to locate the store in the map. It should not be shown to the user.
    var longitude: Float = 0
        // Optional. Store longitude. If available must be used to locate the store in the map. It should not be shown to the user.
}

class Positioning  {
    var required = 0 // Boolean [0/1]
        // Mandatory. Flag showing if the geolocation of the user is required at the beginning and at the end of the job. It should not be shown to the user.
    var start = 0 // Boolean [0/1]
        // Optional. Flag showing if the data to geolocate the user at the beginning of the job have been collected. Must the populate automatically when the user press Start. It should not be shown to the user.
    var start_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time the user press Start. It should not be shown to the user..
    var start_lat:Float = 0
        // Optional. Latitude where the user press Start. It should not be shown to the user.
    var start_lng:Float = 0
        // Optional. Longitude where the user press Start. It should not be shown to the user.
    var end = 0 // Boolean [0/1]
        // Optional. Flag showing the the data for the golocation of the user at the and of the job are been collected. Must be populate automatically when the user press Stop. It should not be shown to the user.

    var end_date = "" // Date and Time [aaaa-mm-dd hh:mm:ss]
        // Optional. Date and time when the user press Stop. It should not be shown to the user.
    var end_lat:Float = 0
        // Optional. Latitude where the user press Stop. It should not be shown to the user.
    var end_lng:Float = 0
        // Optional. Longitude where the user press Stop. It should not be shown to the user.
}
