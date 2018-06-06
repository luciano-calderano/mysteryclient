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
        return Config.File.zipPefix + id + ".zip"
    }
    class func getZipFilePath (id: String) -> String {
        return Config.Path.zip + MYZip.getZipFileName(id: id)
    }
    class func unzip(urlFile: URL, urlDest: URL) {
        try? Zip.unzipFile(urlFile, destination: urlDest, overwrite: true, password: nil)
    }
    
    class func removeZipWithId (_ id: String) {
        do {
            try? FileManager.default.removeItem(atPath: MYZip.getZipFilePath(id: id))
        }
    }
    class func zipFiles (_ files: [URL], toZipFile zipFile: URL) -> Bool {
        do {
            try Zip.zipFiles(paths: files, zipFilePath: zipFile, password: nil, progress: nil)
            return true
        } catch  {
            print("Zip error")
        }
        return false
    }
    
    class func createZipFileWithDict (_ dict: JsonDict) -> Bool {
        let jobId = String(MYJob.shared.job.id)
        let fm = FileManager.default
        
        do {
            let json = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            
            try? json.write(to: URL.init(fileURLWithPath: MYJob.currentJobPath + Config.File.json))
            
            let filesToZip = try fm.contentsOfDirectory(at: URL.init(string: MYJob.currentJobPath)!,
                                                   includingPropertiesForKeys: nil,
                                                   options: [])
            
            let zipFile = URL.init(fileURLWithPath: MYZip.getZipFilePath(id: jobId))
            try Zip.zipFiles(paths: filesToZip,
                             zipFilePath: zipFile,
                             password: nil,
                             progress: nil)
            
            try? fm.removeItem(atPath: MYJob.currentJobPath)
            MYJob.shared.removeJobWithId(MYJob.shared.job.id)
            MYResult.shared.removeResultWithId(MYJob.shared.job.id)
            
            return true
        } catch {
            print("createZipFileWithDict: error")
        }
        return false
    }
}
