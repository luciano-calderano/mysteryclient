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
        let vc = InstanceFromSb("Jobs") as! JobDetail
        return vc
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
        subView.job = MYJob.shared.job
        subView.delegate = self
        view.addSubview(subView)
    }
    
    @IBAction func spreTapped () {
        let ctrl = WebPage.Instance(type: .bookingRemove, id: MYJob.shared.job.id)
        gotoCtrl(ctrl)
    }
    @IBAction func dateTapped () {
        let ctrl = WebPage.Instance(type: .bookingMove, id: MYJob.shared.job.id)
        gotoCtrl(ctrl)
    }
    
    @IBAction func contTapped () {
        guard MYJob.shared.job.learning_done else {
            let ctrl = WebPage.Instance(type: .none)
            ctrl.page = MYJob.shared.job.learning_url
            gotoCtrl(ctrl)
//            navigationController?.show(ctrl, sender: self)
            return
        }
        let wheel = MYWheel()
        wheel.start(view)
        if MYJob.shared.jobResult.execution_date.isEmpty {
            MYJob.shared.jobResult.estimate_date = Date().toString(withFormat: Config.DateFmt.DataJson)
            MYResult.shared.saveResult()
        }
        
        let ctrl = KpiMain.Instance()
        navigationController?.show(ctrl, sender: self)
        wheel.stop()
    }
    
    @IBAction func tickTapped () {
        let ctrl = WebPage.Instance(type: .ticketView)
        gotoCtrl(ctrl)
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
    
    private func gotoCtrl (_ ctrl: WebPage) {
        UIApplication.shared.openURL(URL.init(string: ctrl.page)!)
        //        navigationController?.show(ctrl, sender: self)
    }
    
    private func showData () {
        header?.header.titleLabel.text = MYJob.shared.job.store.name
        infoLabel.text =
            MYLng("rifNum") + ": \(MYJob.shared.job.reference)\n" +
            MYLng("verIni") + ": \(MYJob.shared.job.start_date.toString(withFormat: Config.DateFmt.Data))\n" +
            MYLng("verEnd") + ": \(MYJob.shared.job.end_date.toString(withFormat: Config.DateFmt.Data))\n"
        nameLabel.text = MYJob.shared.job.store.name
        addrLabel.text = MYJob.shared.job.store.address
    }
    
    private func loadAndShowResult () {
        executionTime()
        var title = ""
        if MYJob.shared.job.learning_done == false {
            title = "learning"
        }
        else {
            title = MYJob.shared.jobResult.execution_date.isEmpty ? "kpiInit" : "kpiCont"
        }
        contBtn.setTitle(MYLng(title), for: .normal)
    }
    
    private func executionTime () {
        strtBtn.isEnabled = false
        stopBtn.isEnabled = false
        strtBtn.backgroundColor = UIColor.lightGray
        stopBtn.backgroundColor = UIColor.lightGray
        
        if MYJob.shared.jobResult.positioning.start == false {
            strtBtn.isEnabled = true
            strtBtn.backgroundColor = UIColor.white
        }
        else if MYJob.shared.jobResult.positioning.end == false {
            stopBtn.isEnabled = true
            stopBtn.backgroundColor = UIColor.white
        }
    }
}

// MARK: - Attachment delegate

extension JobDetail: JobDetailAtchDelegate {
    func openFileFromUrlWithString(_ page: String) {
        let ctrl = WebPage.Instance(type: .none)
        ctrl.page = page
        gotoCtrl(ctrl)
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
