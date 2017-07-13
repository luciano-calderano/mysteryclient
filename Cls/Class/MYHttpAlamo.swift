//
//  MYHttp.swift
//  Lc
//
//  Created by Luciano Calderano on 07/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import Alamofire

class MYHttpRequest {
    static let printJson = true
    
    class func get (_ page: String) -> MYHttpRequest {
        let req = MYHttpRequest (baseUrl: Config.url,
                                 page: page,
                                 type: .get)
        return req
    }
    
    class func post (_ page: String) -> MYHttpRequest {
        let req = MYHttpRequest (baseUrl: Config.url,
                                 page: page,
                                 type: .post)
        return req
    }

    var json = JsonDict()
    
    fileprivate let jsonResponse =  UserDefaults.init(suiteName: "Response.json")

    private var type: HTTPMethod!
    fileprivate var page = ""
    fileprivate var url = ""
    fileprivate var token = ""
    fileprivate var myWheel:MYWheel?

    init(baseUrl: String, page: String, type: HTTPMethod) {
        self.page = page
        self.url = baseUrl + page
        self.type = type
    }

    // MARK: - Start
    
    func start (showWheel: Bool = true, silentError: Bool = false, header: Bool = true, completion: @escaping (Bool, JsonDict) -> () = { success, response in }) {
        if showWheel {
            self.startWheel(true)
        }
        self.printJson(self.json)

        let token = User.shared.getToken()
        var headers = [String: String]()
        if header == true {
            headers["Authorization"] = "Bearer " + token
        }
        
        Alamofire.request(self.url, method: self.type, parameters: self.json, headers: headers).responseString { response in
            if showWheel {
                self.startWheel(false)
            }
            let error = "Code: #\(String((response.response?.statusCode)!))"
            var msg = ""
            if response.result.isSuccess {
                let dict = self.removeNullFromJsonString(response.result.value!)
                if response.response?.statusCode == 200 && dict.string("status") == "ok" {
                    self.printJson(dict)
                    completion (true, dict)
                    return
                }

                msg = dict.string("msg")
            }
            else {
                if response.error != nil {
                    msg = (response.error?.localizedDescription)!
                }
            }
            self.showError(title: error, message: msg)
            completion (false, [:])
        }
    }
    
    func removeNullFromJsonString (_ text: String) -> JsonDict {
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
    
    fileprivate func startWheel(_ start: Bool, show: Bool = true, inView: UIView = UIApplication.shared.keyWindow!) {
        guard show else {
            return
        }
        if start {
            self.myWheel = MYWheel()
            self.myWheel?.start(inView)
        }
        else {
            self.myWheel?.stop()
            self.myWheel = nil
        }
    }
}

