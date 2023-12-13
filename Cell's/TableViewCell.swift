//
//  TableViewCell.swift
//  Firebase_Twitter
//
//  Created by Vishal on 11/12/23.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var cellImageView: UIImageView!
    @IBOutlet var cellUserNameLabel: UILabel!
    @IBOutlet var cellEmailLabe: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
