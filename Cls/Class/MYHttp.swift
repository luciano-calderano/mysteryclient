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

enum MYHttpType {
    case grant
    case get
}

import Foundation
import Alamofire

class MYHttp {
    static let printJson = true
    
    private var json = JsonDict()    
    private var type: HTTPMethod!
    private var apiUrl = ""
    private var header = true
    
    private var myWheel:MYWheel?
    
    init(_ httpType: MYHttpType, param: JsonDict, showWheel: Bool = true, hasHeader: Bool = true) {
        json = param
        header = hasHeader
        
        switch httpType {
        case .get:
            type = .get
            apiUrl = Config.Url.get
        case .grant:
            type = .post
            apiUrl = Config.Url.grant
        }
        
        self.startWheel(showWheel)
    }
    
    func load(ok: @escaping (JsonDict) -> (), KO: @escaping (String, String) -> ()) {
        printJson(json)
        var headers = [String: String]()
        if header == true {
            headers["Authorization"] = User.shared.token
            print ("Auth: " + User.shared.token)
        }
        
        Alamofire.request(apiUrl,
                          method: type,
                          parameters: json,
                          headers: headers).responseString { response in
                            self.startWheel(false)
                            let data = self.fixResponse(response)
                            if data.isValid {
                                ok (data.dict)
                            } else {
                                KO (data.dict.string("err"), data.dict.string("msg"))
                            }
        }
    }
    
    func loadAtch(url: String, ok: @escaping (Data) -> ()) {
        printJson(json)
        var headers = [String: String]()
        headers["Authorization"] = User.shared.token

        Alamofire.request(url,
                          method: type,
                          parameters: json,
                          headers: headers).responseString { response in
                            if response.result.isSuccess  {
                                ok(response.data!)
                            }
        }
    }
    
    private func fixResponse (_ response: DataResponse<String>) -> (isValid: Bool, dict: JsonDict) {
        let statusCode = response.response?.statusCode
        let array = apiUrl.components(separatedBy: "/")
        let object = json.string("object")
        let page = object.isEmpty ? (array.last ?? apiUrl) : object
        
        if response.result.isSuccess && statusCode == 200 {
            var dict = removeNullFromJsonString(response.result.value!)
            printJson(dict)
            
            let isValid = dict.string("status") == "ok"
            if isValid == false {
                dict = [ "err" : "Server error \(dict.string("code"))\n[ \(page) ]", "msg" : dict.string("message") ]
            }
            return (isValid, dict)
        }
        let errorMessage = response.error == nil ? "Server error" :  (response.error?.localizedDescription)!
        let dict = [ "err" : "Server error \(statusCode ?? 0)\n[ \(page) ]",  "msg" : errorMessage ]
        return (false, dict)
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
            print("\n[ \(apiUrl) ]\n\(json)\n------------")
        }
    }
    
    fileprivate func startWheel(_ start: Bool, inView: UIView = UIApplication.shared.keyWindow!) {
        if start {
            myWheel = MYWheel()
            myWheel?.start(inView)
        }
        else {
            if let wheel = myWheel {
                wheel.stop()
                myWheel = nil
            }
        }
    }
}


class MYUpload {
    class func startUpload() {
        let me = MYUpload()
        
        do {
            let zipPath = URL.init(string: Config.Path.zip)!
            let files = try FileManager.default.contentsOfDirectory(at: zipPath,
                                                   includingPropertiesForKeys: nil,
                                                   options:[])            
            for file in files {
                if file.pathExtension != Config.File.zip {
                    continue
                }
                let data = try Data.init(contentsOf: file, options: .mappedIfSafe)
                let id = file.deletingPathExtension().lastPathComponent
                me.start(jobId: id, data: data)
            }
        }
        catch {
            print("startUpload: error")
        }
    }
    
    func start (jobId: String, data: Data) {
        let id = Int(jobId)!
        let url = URL.init(string: Config.Url.put)!
        let headers = [
            "Authorization" : User.shared.token
        ]
        
        do {
            let URL = try! URLRequest(url: url, method: .post, headers: headers)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(data,
                                         withName: "object_file",
                                         fileName:  Config.File.idPrefix + MYZip.getZipFileName(id: id),
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
                            print("Upload: Response.JSON: \(JSON)")
                            MYZip.removeZipWithId(id)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
        }
    }
}

