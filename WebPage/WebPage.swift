//
//  WebPage
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

enum WebPageEnum: String {
    case recover = "login/retrieve-password" // ?app=1"
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

class WebPage: MYViewController, UIWebViewDelegate {
    
    class func Instance (type: WebPageEnum, id: Int = 0) -> WebPage {
        let vcName = String (describing: self)
        let sb = UIStoryboard.init(name: "WebPage", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: vcName) as! WebPage
        vc.openPage(type: type, id: id)
        return vc
    }

    @IBOutlet private var webView: UIWebView!
    
//    var pageType = WebPageEnum.none
//    var id = 0
//
    private let homepage = "http://mysteryclient.mebius.it/"

    private var myWheel = MYWheel()
    private var requestObj: URLRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myWheel.start(self.view)
        self.webView.loadRequest(requestObj)
    }
    
    func openPage(type: WebPageEnum, id: Int = 0) {
        var page = self.homepage + type.rawValue
        if id > 0 {
            page += String(id)
        }
        let url = URL.init(string: page)
        self.requestObj = URLRequest.init(url: url!)
        
        let token = User.shared.getToken()
        if token.isEmpty == false {
            self.requestObj.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
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
