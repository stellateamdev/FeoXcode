//
//  DateTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/13/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

class DateTableViewCell: UITableViewCell {
    @IBOutlet weak var time:UILabel!
    @IBOutlet weak var title:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        time.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        time.textColor = UIColor.gray
        title.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)
        title.textColor = UIColor.black
        // Initialization code
    }
    override func prepareForReuse() {
        time.text = ""
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
