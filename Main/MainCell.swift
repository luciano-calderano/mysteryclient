//
//  MainCell.swift
//  MisteryClient
//
//  Created by Lc on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class MainCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView,
                        _ indexPath: IndexPath) -> MainCell {
        let id = String (describing: self)
        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            as! MainCell
    }
    
    var title: String {
        set { self.titleLabel.text = newValue }
        get { return self.titleLabel.text! }
    }
    
    @IBOutlet fileprivate var titleLabel: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.layer.cornerRadius = self.titleLabel.frame.size.height / 2
        self.titleLabel.layer.masksToBounds = true
    }
}

