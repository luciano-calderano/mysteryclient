//
//  JobDetailAtch
//  MysteryClient
//
//  Created by mac on 28/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

protocol JobDetailAtchDelegate {
    func openFileFromUrlWithString (_ page: String)
}

class JobDetailAtch: UIView, UITableViewDelegate, UITableViewDataSource {
    class func Instance() -> JobDetailAtch {
        let id = String (describing: self)
        return Bundle.main.loadNibNamed(id, owner: self, options: nil)?.first as! JobDetailAtch
    }
    
    var job: Job!
    var delegate: JobDetailAtchDelegate?
    
    @IBOutlet private var tableView: UITableView!
    private let cellId = "cellId"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
    }
    
    @IBAction func okTapped () {
        self.removeFromSuperview()
    }
    
    // MARK: - table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.job.attachments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: self.cellId)
        }

        let item = self.job.attachments[indexPath.row]
        cell?.imageView?.image = UIImage.init(named: "ico.download")?.resize(16)
        cell?.textLabel?.text = item.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.job.attachments[indexPath.row]
        print(item)
        self.delegate?.openFileFromUrlWithString(item.url + "/" + item.filename)
    }
}
