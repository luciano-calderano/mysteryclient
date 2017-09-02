//
//  MYHttp.swift
//  MysteryClient
//
//  Created by mac on 17/08/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

enum MYHttpType: String {
    case oauth_grant    = "oauth/grant"
    case rest_get       = "rest/get"
}

import Foundation
import Alamofire

class MYHttp {
    static let printJson = true
    
    private var json = JsonDict()    
    private var type: HTTPMethod!
    private var page = ""
    private var apiUrl = ""
    private var header = true

    private var myWheel:MYWheel?

    init(_ type: MYHttpType, param: JsonDict, showWheel: Bool = true, header: Bool = true) {
        self.page = type.rawValue
        self.apiUrl = Config.apiUrl + self.page
        self.json = param
        self.header = header
        
        switch type {
        case .rest_get:
            self.type = .get
        default:
            self.type = .post
        }

        self.startWheel(showWheel)
    }
    
    func load(ok: @escaping (JsonDict) -> Void = { response in },
              KO: @escaping (String, String) -> Void = { code, error in } ) {

        self.printJson(self.json)
        var headers = [String: String]()
        if self.header == true {
            headers["Authorization"] = User.shared.token
        }
    
        Alamofire.request(self.apiUrl,
                          method: self.type,
                          parameters: self.json,
                          headers: headers).responseString { response in
                            self.startWheel(false)
                            self.response(response,
                                          ok: { (json) in
                                            ok (json)
                                            self.printJson(json)
                            },
                                          KO: { (code, error) in
                                            KO (code, error)
                            })
        }
    }
    
    private func response (_ response: DataResponse<String>,
                           ok: @escaping (JsonDict) -> () = { response in },
                           KO: @escaping (String, String) -> () = { code, error in } ) {
        var statusCode = response.response?.statusCode
        var errorMessage = ""
        
        if response.result.isSuccess {
            let dict = self.removeNullFromJsonString(response.result.value!)
            statusCode = dict.int("code")
            errorMessage = dict.string("status")
            if response.response?.statusCode == 200 && errorMessage == "ok" {
                ok (dict)
                return
            }
        }
        else {
            if response.error != nil {
                errorMessage = (response.error?.localizedDescription)!
            }
            else {
                errorMessage = "Errore generico"
            }
        }
        KO ("\(self.page) - Err. \(statusCode!)", errorMessage)
    }
    
    private func removeNullFromJsonString (_ text: String) -> JsonDict {
        if text.isEmpty {
            return [:]
        }
        
        let jsonString = text.replacingOccurrences(of: ":null", with: ":\"\"")
        if let data = jsonString.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! JsonDict
            } catch {
                print(error.localizedDescription)
            }
        }
        return [:]
    }
    
    // MARK: - private
    
    fileprivate func printJson (_ json: JsonDict) {
        if MYHttp.printJson {
            print("\n[ \(self.apiUrl) ]\n\(json)\n------------")
        }
    }
    
    fileprivate func startWheel(_ start: Bool, inView: UIView = UIApplication.shared.keyWindow!) {
        if start {
            self.myWheel = MYWheel()
            self.myWheel?.start(inView)
        }
        else {
            if self.myWheel != nil {
                self.myWheel?.stop()
                self.myWheel = nil
            }
        }
    }
}


class MYUpload {
    class func startUpload() {
        let me = MYUpload()
        
        let fm = FileManager.default
        do {
            let docUrl = URL.init(string: Config.doc)!
            let files = try fm.contentsOfDirectory(at: docUrl,
                                                   includingPropertiesForKeys: nil,
                                                   options:[])
            
            let results = files.filter{ $0.absoluteString.contains(Config.filePrefix) }
            for file in results {
                let data = try Data.init(contentsOf: file, options: .mappedIfSafe)
                let fileName = file.absoluteString.components(separatedBy: Config.filePrefix).last
                let id = fileName?.components(separatedBy: ".").first
                me.start(jobId: id!, data: data)
            }
        }
        catch {
            print("startUpload: error")
        }
    }
    
    func start (jobId: String, data: Data) {
        let url = URL.init(string: Config.apiUrl + "rest/put")!
        let headers = [
            "Authorization" : User.shared.token
        ]
        
        do {
            let URL = try! URLRequest(url: url, method: .post, headers: headers)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(data,
                                         withName: "object_file",
                                         fileName:  MYZip.getZipFileName(id: jobId),
                                         mimeType: "multipart/form-data")
                
                let json = [
                    "object"        : "job",
                    "object_id"     : jobId,
                ]
                
                for (key, value) in json {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }, with: URL, encodingCompletion: { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let JSON = response.result.value {
                            print("JSON: \(JSON)")
                        }
                        do {
                            try FileManager.default.removeItem(atPath: MYZip.getZipFilePath(id: jobId))
                        }
                        catch {
                            
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
        }
    }
}

