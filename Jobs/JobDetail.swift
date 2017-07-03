//
//  JobDetail.swift
//  MysteryClient
//
//  Created by mac on 27/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class JobDetail: MYViewController, JobDetailAtchDelegate {
    class func Instance(job: Job) -> JobDetail {
        let vc = self.load(storyboardName: "Jobs") as! JobDetail
        vc.job = job
        return vc
    }

    var job: Job!
    private var jobResult = JobResult()
    
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
        self.loadResult()
    }

    // MARK: - actions
    
    @IBAction func mapsTapped () {
        _ = Maps(job: self.job)
    }
    
    @IBAction func descTapped () {
        let subView = JobDetailDesc.Instance()
        subView.frame = self.view.frame
        subView.jobDesc.text = self.job.description
        self.view.addSubview(subView)
    }
    
    @IBAction func atchTapped () {
        let subView = JobDetailAtch.Instance()
        subView.frame = self.view.frame
        subView.job = self.job
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
        let ctrl = KpisList.Instance(job: self.job, jobResult: self.jobResult)
        self.navigationController?.show(ctrl, sender: self)
    }
    
    @IBAction func tickTapped () {
        let ctrl = WebPage.Instance(type: .ticketView)
        self.navigationController?.show(ctrl, sender: self)
    }
    
    @IBAction func strtTapped () {
        self.jobResult.executionStart()
        self.executionTime()
    }
    @IBAction func stopTapped () {
        self.jobResult.executionEnd()
        self.executionTime()
    }

    // MARK: - Attachment delegate
    
    func openFileFromUrlWithString(_ page: String) {
        let ctrl = WebPage.Instance(type: .none)
        ctrl.openPage(page)
        self.navigationController?.show(ctrl, sender: self)
    }

    // MARK: - private
    
    private func showData () {
        self.header?.header.titleLabel.text = self.job.store.name
        self.infoLabel.text = Lng("rifNum") + ": \(self.job.reference)\n" +
            Lng("verIni") + ": " + self.job.start_date.toString(withFormat: "dd/MM/yyyy") + "\n" +
            Lng("verEnd") + ": " + self.job.end_date.toString(withFormat: "dd/MM/yyyy") + "\n"
        self.nameLabel.text = self.job.store.name
        self.addrLabel.text = self.job.store.address
    }
    
    private func loadResult () {
        self.jobResult.load(id: self.job.id)
        self.executionTime()
        let resultsArray = self.jobResult.getResults()
        let title = resultsArray.count == 0 ? "kpiInit" : "kpiCont"
        self.contBtn.setTitle(Lng(title), for: .normal)
    }
    
    private func executionTime () {
        self.strtBtn.isEnabled = false
        self.stopBtn.isEnabled = false
        self.strtBtn.backgroundColor = UIColor.lightGray
        self.stopBtn.backgroundColor = UIColor.lightGray
        
        if self.jobResult.executionNotStarted {
            self.strtBtn.isEnabled = true
            self.strtBtn.backgroundColor = UIColor.white
        }
        else if self.jobResult.executionNotEnded {
            self.stopBtn.isEnabled = true
            self.stopBtn.backgroundColor = UIColor.white
        }
    }
}

