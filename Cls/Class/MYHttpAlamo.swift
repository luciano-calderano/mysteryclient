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
    struct HttpConfig {
        static let url = "http://api.kanito.it/"
        static let token = "olihGYTYV57856-=gg"
    }
    static let printJson = true
    
    class func get (_ page: String) -> MYHttpRequest {
        let req = MYHttpRequest (token: HttpConfig.token,
                                 baseUrl: HttpConfig.url,
                                 page: page,
                                 type: .get)
        return req
    }
    
    class func post (_ page: String) -> MYHttpRequest {
        let req = MYHttpRequest (token: HttpConfig.token,
                                 baseUrl: HttpConfig.url,
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
    fileprivate var parameters: JsonDict {
        get {
            var parameters = self.json
            parameters["token"] = self.token
            return parameters
        }
    }

    init(token: String, baseUrl: String, page: String, type: HTTPMethod) {
        self.page = page
        self.url = baseUrl + page
        self.token = token
        self.type = type
    }

    // MARK: - Start
    
    func start (showWheel: Bool = true, silentError: Bool = false, completion: @escaping (Bool, JsonDict) -> () = { success, response in }) {
        if showWheel {
            self.startWheel(true)
        }
        self.printJson(self.json)
        Alamofire.request(self.url, method: self.type, parameters: self.parameters).responseString { response in
//        Alamofire.request(self.url, method: self.type, parameters: self.parameters).responseJSON { (response) in
            if showWheel {
                self.startWheel(false)
            }
//            let dict = response.value as! JsonDict
            if (response.result.isSuccess) {
                let dict = self.removeNullFromJsonString(response.result.value!)
                if response.response?.statusCode == 200 {
                    self.printJson(dict)
                    do {
                        try self.saveJson(dict)
                    } catch {
                        print("Json: è stata sollevata un'eccezione \(error) ")
                    }
                    completion (true, dict)
                }
                else {
                    let msg = dict.string("msg")
//                    print("Error: " + String(describing: response.response?.statusCode) + " " + msg)
                    if msg.isEmpty == false  && silentError == false {
                        self.showError(title: "", message: msg)
                    }
                    completion (false, [:])
                }
                return
            }
            if response.error != nil {
//                let dict = self.removeNullFromJsonString(response.result.value!)
//                let msg = response.error?.localizedDescription == nil ? dict.string("msg") : (response.error?.localizedDescription)!
//                print("Error: " + String(describing: response.response?.statusCode) + " " + msg)
                completion (false, [:])
                self.showError(title: "", message: (response.error?.localizedDescription)!)
//                print ("Error: " + String(describing: response.response?.statusCode))
            }
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
    
    private func saveJson (_ dict: JsonDict) throws {
//        self.jsonResponse?.setValue(dict, forKey: self.page)
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

