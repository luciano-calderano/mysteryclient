//
//  JobDetail.swift
//  MysteryClient
//
//  Created by mac on 27/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import CoreLocation

class JobDetail: MYViewController {
    class func Instance() -> JobDetail {
        return Instance(sbName: "Jobs", "JobDetail") as! JobDetail
    }
    
    private let locationManager = CLLocationManager()
    private var locationValue = CLLocationCoordinate2D()
    
    @IBOutlet var infoLabel: MYLabel!
    @IBOutlet var nameLabel: MYLabel!
    @IBOutlet var addrLabel: MYLabel!
    
    @IBOutlet var descBtn: MYButton!
    @IBOutlet var alleBtn: MYButton!
    @IBOutlet var spreBtn: MYButton!
    @IBOutlet var dateBtn: MYButton!
    
    @IBOutlet var contBtn: MYButton!
    @IBOutlet var tickBtn: MYButton!
    @IBOutlet var strtBtn: MYButton!
    @IBOutlet var stopBtn: MYButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isAuthorizedtoGetUserLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        for btn in [contBtn, tickBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(16)
            btn.setImage(ico, for: .normal)
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
            btn.layer.shadowColor = UIColor.darkGray.cgColor
            btn.layer.shadowOffset = CGSize.init(width: 0, height: 5)
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.layer.borderWidth = 0.5
            btn.layer.shadowOpacity = 0.2
            btn.layer.masksToBounds = false
        }
        
        for btn in [strtBtn, stopBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(16)
            btn.setImage(ico, for: .normal)
            
            let spacing: CGFloat = 10
            let titleSize = btn.titleLabel!.frame.size
            let imageSize = btn.imageView!.frame.size
            let center = btn.frame.size.width / 2
            
            btn.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: center - imageSize.width/2, bottom: 0, right: -titleSize.width)
            
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(titleSize.width + imageSize.width) / 2, bottom: -(imageSize.height + spacing), right: 0)
        }
        
        showData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAndShowResult()
    }
    
    // MARK: - actions
    
    @IBAction func mapsTapped () {
        let store = MYJob.shared.job.store
        _ = Maps.init(lat: store.latitude,
                      lon: store.longitude,
                      name: store.name)
    }
    
    @IBAction func descTapped () {
        let subView = JobDetailDesc.Instance()
        subView.frame = view.frame
        subView.jobDesc.text = MYJob.shared.job.description
        view.addSubview(subView)
    }
    
    @IBAction func atchTapped () {
        let subView = JobDetailAtch.Instance()
        subView.frame = view.frame
        subView.delegate = self
        view.addSubview(subView)
    }
    
    @IBAction func spreTapped () {
        openWeb(type: .bookingRemove, id: MYJob.shared.job.id)
    }
    @IBAction func dateTapped () {
        openWeb(type: .bookingMove, id: MYJob.shared.job.id)
    }
    
    @IBAction func contTapped () {
        if MYJob.shared.jobResult.execution_date.isEmpty {
            guard MYJob.shared.job.learning_done else {
                openWeb(type: .none, urlPage:  MYJob.shared.job.learning_url)
                MYJob.shared.job.learning_done = true
                loadAndShowResult()
                return
            }
            MYJob.shared.jobResult.estimate_date = Date().toString(withFormat: Config.DateFmt.DataJson)
            MYResult.shared.saveResult()
        }
        let wheel = MYWheel()
        wheel.start(view)
        
        let ctrl = KpiMain.Instance()
        navigationController?.show(ctrl, sender: self)
        wheel.stop()
    }
    
    @IBAction func tickTapped () {
        openWeb(type: .ticketView)
    }
    
    @IBAction func strtTapped () {
        locationManager.startUpdatingLocation()
        executionTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            MYJob.shared.jobResult.positioning.start = true
            MYJob.shared.jobResult.positioning.start_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
            MYJob.shared.jobResult.positioning.start_lat = self.locationValue.latitude
            MYJob.shared.jobResult.positioning.start_lng = self.locationValue.longitude
            MYResult.shared.saveResult()
            
            self.locationManager.stopUpdatingLocation()
        }
    }
    @IBAction func stopTapped () {
        locationManager.startUpdatingLocation()
        executionTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            MYJob.shared.jobResult.positioning.end = true
            MYJob.shared.jobResult.positioning.end_date = Date().toString(withFormat: Config.DateFmt.DataOraJson)
            MYJob.shared.jobResult.positioning.end_lat = self.locationValue.latitude
            MYJob.shared.jobResult.positioning.end_lng = self.locationValue.longitude
            if MYJob.shared.jobResult.execution_end_time.isEmpty {
                MYJob.shared.jobResult.execution_end_time = Date().toString(withFormat: Config.DateFmt.Ora)
            }
            MYResult.shared.saveResult()
            
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    // MARK: - private
    
    private func showData () {
        header?.header.titleLabel.text = MYJob.shared.job.store.name
        infoLabel.text =
            Lng("rifNum") + ": \(MYJob.shared.job.reference)\n" +
            Lng("verIni") + ": \(MYJob.shared.job.start_date.toString(withFormat: Config.DateFmt.Data))\n" +
            Lng("verEnd") + ": \(MYJob.shared.job.end_date.toString(withFormat: Config.DateFmt.Data))\n"
        nameLabel.text = MYJob.shared.job.store.name
        addrLabel.text = MYJob.shared.job.store.address
    }
    
    private func loadAndShowResult () {
        executionTime()
        var title = ""
        if  MYJob.shared.jobResult.execution_date.isEmpty == false {
            title = "kpiCont"
        } else if MYJob.shared.job.learning_done == false {
            title = "learning"
        } else {
            title = "kpiInit"
        }
        contBtn.setTitle(Lng(title), for: .normal)
    }
    
    private func executionTime () {
        strtBtn.isEnabled = false
        stopBtn.isEnabled = false
        strtBtn.backgroundColor = .lightGray
        stopBtn.backgroundColor = .lightGray
        
        if MYJob.shared.jobResult.positioning.start == false {
            strtBtn.isEnabled = true
            strtBtn.backgroundColor = UIColor.white
        } else if MYJob.shared.jobResult.positioning.end == false {
            stopBtn.isEnabled = true
            stopBtn.backgroundColor = UIColor.white
        }
    }
}

extension JobDetail {
    private func openWeb (type: WebPage.WebPageEnum, id: Int = 0, urlPage: String = "") {
        let ctrl = WebPage.Instance(type: type, id: id)
        if urlPage.isEmpty == false {
            ctrl.page = urlPage
        }
        navigationController?.show(ctrl, sender: self)
        
        //        var page = urlPage
        //        if page.isEmpty {
        //            page = Config.Url.home + type.rawValue
        //            if id > 0 {
        //                page += String(id)
        //            }
        //        }
        //        UIApplication.shared.openURL(URL.init(string: page)!)
    }
}

// MARK: - Attachment delegate

extension JobDetail: JobDetailAtchDelegate {
    func openFileFromUrlWithString(_ page: String) {
        openWeb(type: .none, urlPage: page)
    }
}

// MARK: - Location manager delegate

extension JobDetail: CLLocationManagerDelegate {
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationValue = (manager.location?.coordinate)!
        print("Loc. \(locationValue)")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location updates error \(error)")
    }
}
