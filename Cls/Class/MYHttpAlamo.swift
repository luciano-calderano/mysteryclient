//
//  MYHttp.swift
//  Lc
//
//  Created by Luciano Calderano on 07/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import Alamofire

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

typealias responseBlock = (Bool, JsonDict) -> ()

class MYHttpRequest {
    static let printJson = true
    
    init(_ page: String) {
        self.page = page
        self.url = Config.url + page
    }
    
    var json = JsonDict()
    
    private var type: HTTPMethod!
    private var page = ""
    private var url = ""
    private var myWheel:MYWheel?
    
    // MARK: - Start
    
    func get (showWheel: Bool = true, header: Bool = true, completion: @escaping responseBlock = { success, response in }) {
        self.type = .get
        self.start(showWheel: showWheel, header: header) { (success, response) in
            completion (success, response)
        }
    }
    
    func post (showWheel: Bool = true, header: Bool = true, completion: @escaping responseBlock = { success, response in }) {
        self.type = .post
        self.start(showWheel: showWheel, header: header) { (success, response) in
            completion (success, response)
        }
    }
    
    func put (data: Data, showWheel: Bool = true, completion: @escaping responseBlock = { success, response in }) {
        self.type = .put
        self.start(showWheel: showWheel, header: true) { (success, response) in
            completion (success, response)
        }
    }
    
    private func start (showWheel: Bool = true, header: Bool = true, completion: @escaping responseBlock = { success, response in }) {
        self.startWheel(showWheel)
        self.printJson(self.json)
        
        var urlRequest = URLRequest(url: URL(string: self.url)!)
        urlRequest.httpMethod = self.type.rawValue
        if header == true {
            urlRequest.setValue("Bearer " + User.shared.getToken(), forHTTPHeaderField: "Authorization")
        }
        
        var headers = [String: String]()
        if header == true {
            headers["Authorization"] = "Bearer " + User.shared.getToken()
        }
        
        Alamofire.request(self.url, method: self.type, parameters: self.json, headers: headers).responseString { response in
            self.startWheel(false)
            self.response(response, completion: { (success, json) in
                completion (success, json)
            })
        }
    }
    
    private func response (_ response: DataResponse<String>, completion: @escaping responseBlock = {
        (success, response) in }) {
        let error = "Code: #\(String((response.response?.statusCode)!))"
        var msg = ""
//        let z = response.request?.httpBody
//        if z != nil {
//            let s = String.init(data: z!, encoding: .utf8)
//            print (s ?? "")
//        }
        if response.result.isSuccess {
            let dict = self.removeNullFromJsonString(response.result.value!)
            msg = dict.string("code")
            if response.response?.statusCode == 200 && dict.string("status") == "ok" {
                self.printJson(dict)
                completion (true, dict)
                return
            }
        }
        else {
            if response.error != nil {
                msg = (response.error?.localizedDescription)!
            }
        }
        self.showError(title: error, message: msg)
        completion (false, [:])
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
    
    private func showError (title: String, message: String) {
        let alert = UIAlertController(title: title as String, message: message  as String, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        
        let topVC = UIApplication.shared.windows[0].rootViewController
        topVC?.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func printJson (_ json: JsonDict) {
        if MYHttpRequest.printJson {
            print("\n[ \(self.url) ]\n\(json)\n------------")
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

