//
//  JsonDictExtension.swift
//  Lc
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import Foundation

extension String {
    func tryLang() -> String {
        var s = self as String
        if (s.count > 0) {
            if s[s.startIndex..<s.index(s.startIndex, offsetBy: 1)] == "#" {
                s = String(s[s.index(s.startIndex, offsetBy: 1)..<s.endIndex])
                s = Lng(s)
            }
        }
        
        let newLine = "\n"
        return s.replacingOccurrences(of: "\\n", with: newLine)
    }
    
    func left(_ numOfChars: Int) -> String {
        if (self.count < numOfChars) {
            return ""
        }
        else {
            return String(self[self.startIndex..<self.index(self.startIndex, offsetBy: numOfChars)])
        }
    }
    
    func range (_ iniz: Int, fine: Int) -> String {
        let ini = self.index(self.startIndex, offsetBy: iniz)
        let end = self.index(self.startIndex, offsetBy: fine)
        let s = self[ini..<end]
        return String(s)
    }
}
