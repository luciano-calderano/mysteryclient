//
//  JobDetail.swift
//  MysteryClient
//
//  Created by mac on 27/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit
import CoreLocation

class JobDetail: MYViewController, JobDetailAtchDelegate, CLLocationManagerDelegate {
    class func Instance() -> JobDetail {
        let vc = self.load(storyboardName: "Jobs") as! JobDetail
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
        self.isAuthorizedtoGetUserLocation()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        for btn in [self.contBtn, self.tickBtn] as! [MYButton] {
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
        
        for btn in [self.strtBtn, self.stopBtn] as! [MYButton] {
            let ico = btn.image(for: .normal)?.resize(16)
            btn.setImage(ico, for: .normal)
            
            let spacing: CGFloat = 10
            let titleSize = btn.titleLabel!.frame.size
            let imageSize = btn.imageView!.frame.size
            let center = btn.frame.size.width / 2
            
            btn.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: center - imageSize.width/2, bottom: 0, right: -titleSize.width)

            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(titleSize.width + imageSize.width) / 2, bottom: -(imageSize.height + spacing), right: 0)
        }
        
        self.showData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadAndShowResult()
    }
    
    // MARK: - Location manager
    
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationValue = (manager.location?.coordinate)!
        print("Loc. \(self.locationValue)")
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location updates error \(error)")
    }
    
    // MARK: - actions
    
    @IBAction func mapsTapped () {
        _ = Maps(job: MYJob.shared.job)
    }
    
    @IBAction func descTapped () {
        let subView = JobDetailDesc.Instance()
        subView.frame = self.view.frame
        subView.jobDesc.text = MYJob.shared.job.description
        self.view.addSubview(subView)
    }
    
    @IBAction func atchTapped () {
        let subView = JobDetailAtch.Instance()
        subView.frame = self.view.frame
        subView.job = MYJob.shared.job
        subView.delegate = self
        self.view.addSubview(subView)
    }
    
    @IBAction func spreTapped () {
        let ctrl = WebPage.Instance(type: .bookingRemove)
        self.navigationController?.show(ctrl, sender: self)
    }
    @IBAction func dateTapped () {
        let ctrl = WebPage.Instance(type: .bookingMove)
        self.navigationController?.show(ctrl, sender: self)
    }
    
    @IBAction func contTapped () {
        guard MYJob.shared.job.learning_done else {
            let ctrl = WebPage.Instance(type: .none)
            ctrl.page = MYJob.shared.job.learning_url
            self.navigationController?.show(ctrl, sender: self)
            return
        }
        if MYJob.shared.jobResult.execution_date.isEmpty {
            MYJob.shared.jobResult.estimate_date = Date().toString(withFormat: Date.fmtDataJson)
            MYResult.shared.saveResult()
        }

        let ctrl = KpiMain.Instance()
        self.navigationController?.show(ctrl, sender: self)
    }
    
    @IBAction func tickTapped () {
        let ctrl = WebPage.Instance(type: .ticketView)
        self.navigationController?.show(ctrl, sender: self)
    }
    
    @IBAction func strtTapped () {
        self.locationManager.startUpdatingLocation()
        self.executionTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            MYJob.shared.jobResult.positioning.start = true
            MYJob.shared.jobResult.positioning.start_date = Date().toString(withFormat: Date.fmtDataOraJson)
            MYJob.shared.jobResult.positioning.start_lat = self.locationValue.latitude
            MYJob.shared.jobResult.positioning.start_lng = self.locationValue.longitude
            MYResult.shared.saveResult()
            
            self.locationManager.stopUpdatingLocation()
        }
    }
    @IBAction func stopTapped () {
        self.locationManager.startUpdatingLocation()
        self.executionTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            MYJob.shared.jobResult.positioning.end = true
            MYJob.shared.jobResult.positioning.end_date = Date().toString(withFormat: Date.fmtDataOraJson)
            MYJob.shared.jobResult.positioning.end_lat = self.locationValue.latitude
            MYJob.shared.jobResult.positioning.end_lng = self.locationValue.longitude
            if MYJob.shared.jobResult.execution_end_time.isEmpty {
                MYJob.shared.jobResult.execution_end_time = Date().toString(withFormat: Date.fmtOra)
            }
            MYResult.shared.saveResult()
            
            self.locationManager.stopUpdatingLocation()
        }
    }

    // MARK: - Attachment delegate
    
    func openFileFromUrlWithString(_ page: String) {
        let ctrl = WebPage.Instance(type: .none)
        ctrl.page = page
        self.navigationController?.show(ctrl, sender: self)
    }

    // MARK: - private
    
    private func showData () {
        self.header?.header.titleLabel.text = MYJob.shared.job.store.name
        self.infoLabel.text =
            Lng("rifNum") + ": \(MYJob.shared.job.reference)\n" +
            Lng("verIni") + ": \(MYJob.shared.job.start_date.toString(withFormat: Date.fmtData))\n" +
            Lng("verEnd") + ": \(MYJob.shared.job.end_date.toString(withFormat: Date.fmtData))\n"
        self.nameLabel.text = MYJob.shared.job.store.name
        self.addrLabel.text = MYJob.shared.job.store.address
    }
    
    private func loadAndShowResult () {
        self.executionTime()
        var title = ""
        if MYJob.shared.job.learning_done == false {
            title = Lng("learning")
        }
        else {
            title = MYJob.shared.jobResult.execution_date.isEmpty ? "kpiInit" : "kpiCont"
        }
        self.contBtn.setTitle(Lng(title), for: .normal)
    }
    
    private func executionTime () {
        self.strtBtn.isEnabled = false
        self.stopBtn.isEnabled = false
        self.strtBtn.backgroundColor = UIColor.lightGray
        self.stopBtn.backgroundColor = UIColor.lightGray
        
        if MYJob.shared.jobResult.positioning.start == false {
            self.strtBtn.isEnabled = true
            self.strtBtn.backgroundColor = UIColor.white
        }
        else if MYJob.shared.jobResult.positioning.end == false {
            self.stopBtn.isEnabled = true
            self.stopBtn.backgroundColor = UIColor.white
        }
    }
}

