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
import MYLib

typealias JsonDict = Dictionary<String, Any>
func Lng(_ key: String) -> String {
    return MYLang.value(key)
}

struct Config {
    struct Url {
        static let home  = "https://mysteryclient.mebius.it/"
        static let grant = Config.Url.home + "default/oauth/grant"
        static let get   = Config.Url.home + "default/rest/get"
        static let put   = Config.Url.home + "default/rest/put"
        static let maps  = "http://maps.apple.com/?"
    }

    struct File {
        static let json = "/job.json"
        static let zipPefix = "id_"
        static let zipSentPrefix = "sent_"
        static let plist = ".plist"
    }

    struct Path {
        static let doc = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
        static let jobs = Config.Path.doc + "jobs/"
        static let result = Config.Path.doc + "result/"
    }

    
    struct DateFmt {
        static let Ora           = "HH:mm"
        static let DataJson      = "yyyy-MM-dd"
        static let DataOraJson   = "yyyy-MM-dd HH:mm:ss"
        static let Data          = "dd/MM/yyyy"
        static let DataOra       = "dd/MM/yyyy HH:mm"
    }

    static let maxPicSize = 1200
}
