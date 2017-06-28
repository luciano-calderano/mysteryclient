//
//  Extension.Date.swift
//  Lc
//
//  Created by Luciano Calderano on 09/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import Foundation

extension String {
    func toDate(withFormat fmt: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = fmt
        return df.date(from: self)!
    }

    func dateConvert(_ fmtIn: String, fmtOut: String) -> String {
        let d = self.toDate(withFormat: fmtIn)
        return d.toString(withFormat: fmtOut)
    }
}

extension Date {
    static let fmtOra           = "HH:mm"
    static let fmtDataJson      = "yyyy-MM-dd"
    static let fmtDataOraJson   = "yyyy-MM-dd HH:mm:ss"
    static let fmtData          = "dd/MM/yyyy"
    static let fmtDataOra       = "dd/MM/yyyy HH:mm"

    func toString(withFormat fmt: String) -> String {
        let df = DateFormatter()
        df.dateFormat = fmt
        return df.string(from: self)
    }
}
