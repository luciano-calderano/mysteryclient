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
    class func removeZipWithId (_ id: String) {
        do {
            try? FileManager.default.removeItem(atPath: MYZip.getZipFilePath(id: id))
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
