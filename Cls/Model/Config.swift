//
//  Config.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//
// git: mcappios@git.mebius.it:projects/mcappios - Pw: Mc4ppIos
// web: mysteryclient.mebius.it - User: utente_gen - Pw: novella44

import Foundation

typealias JsonDict = Dictionary<String, Any>

struct Config {
    static let homePage = "https://mysteryclient.mebius.it/"
    static let apiUrl = Config.homePage + "default/"

    static let mapUrl = "http://maps.apple.com/?"

    static let filePrefix = "id_"
    static let plist = ".plist"

    static let doc = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
    static let jobsPath = Config.doc + "jobs/"
    static let resultPath = Config.doc + "result/"

    static let maxPicSize = 1200
}
