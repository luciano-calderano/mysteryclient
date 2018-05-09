//
//  MYZip.swift
//  MysteryClient
//
//  Created by mac on 02/09/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import Foundation
import Zip

class MYZip {
    class func getZipFileName (id: String) -> String {
        return Config.filePrefix + id + ".zip"
    }
    class func getZipFilePath (id: String) -> String {
        return Config.Path.doc + MYZip.getZipFileName(id: id)
    }
    class func reopenSentZip (ID: Int) {
        func reloadJsonWithId (_ id: Int) -> JsonDict {
            let fromFile = "\(Config.Path.doc)/\(id)/job.json"
            do {
                let url = URL.init(fileURLWithPath: fromFile)
                let data = try Data.init(contentsOf:url)
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: []) as! JsonDict
                    return dict
                } catch {
                    print(error.localizedDescription)
                }
            }
            catch let error as NSError {
                print("Error creating Dictionary: \(error.localizedDescription)")
            }
            return JsonDict()
        }

        let fm = FileManager.default
        let id = String(ID)
        let file = MYZip.getZipFilePath(id: id)
        let sent = file.replacingOccurrences(of: Config.filePrefix, with: Config.zipSentPrefixt)
        if fm.fileExists(atPath: sent) {
            let urlFile = URL.init(string: sent)!
            let urlDest = URL.init(string: "\(Config.Path.doc)/\(MYJob.shared.job.id)")!
            try? Zip.unzipFile(urlFile, destination: urlDest, overwrite: true, password: nil)
            let dict = reloadJsonWithId(MYJob.shared.job.id)
            MYJob.shared.jobResult = MYResult.shared.resultWithDict(dict)
            try? fm.removeItem(atPath: sent)
        }
        

    }
    
    class func removeZipWithId (_ id: String) {
        let file = "file://" + MYZip.getZipFilePath(id: id)
        let sent = file.replacingOccurrences(of: Config.filePrefix, with: Config.zipSentPrefixt)
        do {
            try FileManager.default.moveItem(at: URL.init(string: file)!,
                                             to: URL.init(string: sent)!)
        } catch let error as NSError {
            print(error)
        }
    }

    
    
    func createZipFileWithDict (_ dict: JsonDict) -> Bool {
        let jobId = String(MYJob.shared.job.id)
        let fm = FileManager.default
        let jobPath = Config.Path.doc + jobId
        
        do {
        let json = try JSONSerialization.data(withJSONObject: dict,
                                              options: .prettyPrinted)
            
            try? json.write(to: URL.init(fileURLWithPath: jobPath + "/job.json"))
            
            let filesToZip = try fm.contentsOfDirectory(at: URL.init(string: jobPath)!,
                                                   includingPropertiesForKeys: nil,
                                                   options: [])
            
            let zipFile = URL.init(fileURLWithPath: MYZip.getZipFilePath(id: jobId))
            try Zip.zipFiles(paths: filesToZip,
                             zipFilePath: zipFile,
                             password: nil,
                             progress: nil)
            
            try? fm.removeItem(atPath: jobPath)
            MYJob.shared.removeJobWithId(MYJob.shared.job.id)
            MYResult.shared.removeResultWithId(MYJob.shared.job.id)
            
            return true
        } catch {
            print("createZipFileWithDict: error")
        }
        return false
    }
}
