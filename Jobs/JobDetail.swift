//
//  JobDetail.swift
//  MysteryClient
//
//  Created by mac on 27/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class JobDetail: MYViewController {
    class func Instance(job: Job) -> JobDetail {
        let vc = self.load(storyboardName: "Jobs") as! JobDetail
        vc.job = job
        return vc
    }

    var job: Job!
    
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
        
        
        self.header?.header.titleLabel.text = self.job.store.name
        
        self.infoLabel.text = Lng("rifNum") + ": \(self.job.reference)\n" +
            Lng("verIni") + ": " + self.job.start_date.toString(withFormat: "dd/MM/yyyy") + "\n" +
            Lng("verEnd") + ": " + self.job.end_date.toString(withFormat: "dd/MM/yyyy") + "\n"
        self.nameLabel.text = self.job.store.name
        self.addrLabel.text = self.job.store.address
    }
    
    @IBAction func descTapped () {
        let subView = JobDetailDesc.Instance()
        subView.frame = self.view.frame
        subView.jobDesc.text = self.job.description
        self.view.addSubview(subView)
    }
    
    @IBAction func alleTapped () {
        let subView = JobDetailAlle.Instance()
        subView.frame = self.view.frame
        subView.job = self.job
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
        
    }
    @IBAction func tickTapped () {
        let ctrl = WebPage.Instance(type: .ticketView)
        self.navigationController?.show(ctrl, sender: self)
    }
    
    @IBAction func strtTapped () {
        
    }
    @IBAction func stopTapped () {
        
    }
}

