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
    
//    func put (data: Data, showWheel: Bool = true, completion: @escaping responseBlock = { success, response in }) {
//        let s =  MYUpload.init(url: self.url, data: data, json: self.json)
//        s.start()
//        
////        self.type = .put
////        self.start(showWheel: showWheel, header: true) { (success, response) in
////            completion (success, response)
////        }
//    }
    
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

/*
 
 @Multipart
 @POST(API.PUT)
 Call<BaseResponse> putJob(
 @Header("Authorization") String token,
 @Part("object") RequestBody object,
 @Part("object_id") RequestBody objectID,
 @Part MultipartBody.Part file);
 
 /** Get jobs **/
 public static void putJob(Context context, int jobID, String filePath, Callback<BaseResponse> callback) {
 File file = new File(filePath);
 RequestBody requestFile = RequestBody.create(MediaType.parse("multipart/form-data"), file);
 // MultipartBody.Part is used to send also the actual file name
 MultipartBody.Part body =
 MultipartBody.Part.createFormData("object_file", file.getName(), requestFile);
 
 RequestBody object = RequestBody.create(MediaType.parse("text/plain"), "job");
 RequestBody objectID = RequestBody.create(MediaType.parse("text/plain"), ""+jobID);
 NetworkManager.getRESTService().putJob(
 getAuthToken(context),
 object,
 objectID,
 body
 ).enqueue(callback);
 }<
 */


class MYUpload {
    var url:URL!
    var data: Data!
    let file = String(MYJob.shared.job.id)
    let token = "Bearer " + User.shared.getToken()
    
    
    init(url: String, data: Data) {
        self.url = URL.init(string: url)!
        self.data = data
    }
    
    func createRequest() throws -> URLRequest {
        let boundary = "--- MysteryClient iOS ---"
        
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue(self.token, forHTTPHeaderField: "Authorization")

        let json = [
            "object"        : "job",
            "object_id"     : self.file,
        ]
        request.httpBody = try self.createBody(with: json, boundary: boundary)
        
        return request
    }

    func createBody(with parameters: JsonDict, boundary: String) throws -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
//        "object_file"   : name + ".zip",

        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"object_file\"; filename=\"\(self.file)\"\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"object_file\"\r\n".data(using: .utf8)!)
        
        body.append("Content-Type: multipart/form-data\r\n\r\n".data(using: .utf8)!)
        body.append(self.data)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }

    func start () {
        let request: URLRequest
        do {
            request = try self.createRequest()
            print(request)
        }
        catch {
            print("error")

            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                // handle error here
                print(error!)
                return
            }
            
            // if response was JSON, then parse it
            
            do {
                let s = String.init(data: data!, encoding: .utf8)
                print (s)
                let responseDictionary = try JSONSerialization.jsonObject(with: data!)
                print("success == \(responseDictionary)")
                // DispatchQueue.main.async {
                //     // update your UI and model objects here
                // }
            } catch {
                print(error)
                
                let responseString = String(data: data!, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
            }
        }
        task.resume()
        
    }
}
