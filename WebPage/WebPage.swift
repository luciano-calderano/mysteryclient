//
//  WebPage
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import WebKit

class WebPage: MYViewController, UIWebViewDelegate {
    enum WebPageEnum: String {
        case recover = "login/retrieve-password?app=1"
        case register = "login/register?app=1"
        
        case profile = "mystery/profile"
        case storico = "checking/validated"
        case cercando = "mystery/communications"
        case news = "mystery/news"
        case contattaci = "ticket"
        case learning = "learning"
        
        case bookingRemove = "checking/booking-remove?id="
        case bookingMove = "checking/booking-move?id="
        case ticketView = "checking/ticket-view?id="
        case none = ""
    }
   
    class func Instance (type: WebPageEnum, id: Int = 0) -> WebPage {
        let vcName = String (describing: self)
        let sb = UIStoryboard.init(name: "WebPage", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: vcName) as! WebPage
        if type != .none {
            var page = Config.homePage + type.rawValue
            if id > 0 {
                page += String(id)
            }
            vc.page = page
        }

        return vc
    }

    @IBOutlet private var webView: UIWebView!

    var page = ""
    
    private var myWheel = MYWheel()
    private var requestObj: URLRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.myWheel.start(self.webView)
        if self.page.isEmpty {
            return
        }
        
        self.requestObj = URLRequest.init(url: URL.init(string: self.page)!)
        
        let token = User.shared.token
        if token.isEmpty == false {
            self.requestObj.setValue(token, forHTTPHeaderField: "Authorization")
        }

        self.webView.loadRequest(requestObj)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.myWheel.stop()
    }
    
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        if request.url == url { // || request.url! == URL.init(string: Config.basePath) {
//            return true
//        }
//        self.navigationController?.popToRootViewController(animated: true)
//        return false
//    }
}
