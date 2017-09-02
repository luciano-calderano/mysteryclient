
import Foundation

extension Dictionary {
    private func getVal(_ keys: String) -> Any? {
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
        if value is Bool {
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

    func bool (_ key: String) -> Bool {
        guard let ret = self.getVal(key) as? String else {
            return false
        }
        return ret == "1"
    }

    func date (_ key: String, fmt: String) -> Date? {
        guard let ret = self.getVal(key) as? String else {
            return Date.init(timeIntervalSince1970: 0)
        }
        if ret.isEmpty {
            return nil
        }
        let d = ret.toDate(withFormat: fmt)
        return d
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

    //MARK:- Disk utility
    
    init (fromFile: String) {
        self.init()
        guard FileManager.default.fileExists(atPath: fromFile) else {
            return
        }
        do {
            let url = URL.init(fileURLWithPath: fromFile)
            let data = try Data.init(contentsOf:url)//
            
            let dict = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as! Dictionary<Key, Value>
            for key in dict.keys {
                self[key] = dict[key]
            }
        }
        catch let error as NSError {
            fatalError("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    func saveToFile(_ file: String) -> Bool {
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: self,
                                                          format: .binary,
                                                          options: .allZeros)
            try data.write(to: URL.init(fileURLWithPath: file))
            return true
        }
        catch let error as NSError {
            fatalError("Error creating directory: \(error.localizedDescription)")
        }
        return false
    }
}

