
//        let sortedResults = arr.sorted (by: {
//            (dictOne:Any, dictTwo:Any) -> Bool in
//
//            func eventDate(dict: JsonDict) -> String {
//                let s = dict.string("Event.event_start")
//                let date = s.range(iniz: 6, fine: 10) + s.range(iniz: 3, fine: 5) + s.range(iniz: 0, fine: 2)
//                return date
//            }
//            let date1 = eventDate(dict: dictOne as! JsonDict)
//            let date2 = eventDate(dict: dictTwo as! JsonDict)
//
//            return date1 > date2
//        })

import Foundation

extension Dictionary {
    func getVal(_ keys: String) -> Any? {
        let array = keys.components(separatedBy: ".")

        var dic = self as Dictionary<Key, Value>
        for key in array.dropLast() {
            guard let next = dic[key as! Key] else {
                return nil
            }
            guard next is Dictionary<Key, Value> else {
                return nil
            }
            
            dic = next as! Dictionary<Key, Value>
        }
        
        guard let value = dic[array.last! as! Key] else {
            return nil
        }
        
        if value is String {
            return value as! String
        }
        if value is Array<Any> {
            return value as! Array<Any>
        }
        if value is Dictionary {
            return value as! Dictionary
        }
        if value is Double {
            return String (describing: value)
        }
        if value is Int {
            return String (describing: value)
        }
        return nil
    }

    func double (_ key: String) -> Double {
        guard let ret = self.getVal(key) as? String else {
            return 0
        }
        return ret.isEmpty ? 0 : Double(ret)!
    }

    func int (_ key: String) -> Int {
        guard let ret = self.getVal(key) as? String else {
            return 0
        }
        return ret.isEmpty ? 0 : Int(ret)!
    }
    
    func string (_ key: String) -> String {
        guard let ret = self.getVal(key) as? String else {
            return ""
        }
        return ret
    }
    
    func dictionary(_ key: String) -> JsonDict {
        guard let ret = self.getVal(key) as? JsonDict else {
            return [:]
        }
        return ret
    }
    
    func array(_ key: String) -> Array<Any> {
        guard let ret = self.getVal(key) as? Array<Any> else {
            return []
        }
        return ret
    }
}

